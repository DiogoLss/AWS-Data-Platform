from cadwyn import endpoint
import requests
import os
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

api_key = os.getenv("RIOT_API_KEY")
databricks_token = os.getenv("DATABRICKS_TOKEN")

params = {
    'api_key': api_key
}

bucket_name = 'aws-data-660273306079'

def save_data_to_s3(data, table_name):
    import json
    data = json.dumps(data)
    import boto3
    s3 = boto3.client('s3')

    date = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
    table_name = f'raw/lol/{table_name}/{date}.json'
    if data is not None:
        s3.put_object(Bucket=bucket_name, Key=table_name, Body=data)
        print(f'Data saved to S3: {table_name}')

def get_api_data(region, endpoint, params=params):
    if region == 'americas':
        url = 'https://americas.api.riotgames.com/'
    elif region == 'br':
        url = 'https://br1.api.riotgames.com/'

    
    response = requests.get(f'{url}{endpoint}', params=params)
    if response.status_code == 200:
        return response.json()
    else:
        print(f'Error fetching data: {response.status_code} - {response.text}')

def get_account():
    acc_data = get_api_data('americas', 'riot/account/v1/accounts/by-riot-id/Pia D Bosta/4707')
    save_data_to_s3(acc_data, 'account')
    return acc_data['puuid']

def get_mastery(acc_id):
    mastery_data = get_api_data('br', f'/lol/champion-mastery/v4/champion-masteries/by-puuid/{acc_id}')
    save_data_to_s3(mastery_data, 'mastery')

def get_last_timestamp():
    from databricks import sql
    import os

    connection = sql.connect(
                            server_hostname = "dbc-30ec6529-3806.cloud.databricks.com",
                            http_path = "/sql/1.0/warehouses/77f483e3781a37ea",
                            access_token = databricks_token)
    cursor = connection.cursor()

    cursor.execute("SELECT MAX(from_unixtime(info_gameCreation / 1000)) AS dt from bronze.lol.matches")
    result = cursor.fetchone()
    
    cursor.close()
    connection.close()
    if result[0] is None:
        return None
    return int(datetime.strptime(result[0], "%Y-%m-%d %H:%M:%S").timestamp())

def get_matches_list(acc_id):
    last_ts = get_last_timestamp()

    if last_ts is None:
        start_time = int(datetime(2021, 6, 16).timestamp())
    else:
        SAFE_DELAY = 2 * 60 * 60
        start_time = last_ts - SAFE_DELAY

    all_matches = []
    start = 0
    count = 100

    while True:
        params_matches_list = params.copy()
        params_matches_list['start'] = start
        params_matches_list['count'] = count
        params_matches_list['startTime'] = start_time

        matches = get_api_data(
            'americas',
            f'/lol/match/v5/matches/by-puuid/{acc_id}/ids',
            params_matches_list
        )

        if not matches:
            break

        all_matches.extend(matches)
        start += count

    save_data_to_s3(all_matches, 'matches_list')
    return all_matches

def get_matches(all_matches):
    for match_id in all_matches:
        try:
            match_data = get_api_data(
                'americas',
                f'/lol/match/v5/matches/{match_id}',
                params  # pode manter ou até tirar se estiver usando header
            )

            save_data_to_s3(match_data, 'matches')

            # 🔥 evita rate limit
            import time
            time.sleep(1)
            
        except Exception as e:
            print(f"Erro no match {match_id}: {e}")

def get_champions():
    data = requests.get('https://ddragon.leagueoflegends.com/cdn/16.6.1/data/en_US/champion.json').json()
    save_data_to_s3(data, 'champions_list')
    return data['data'].keys()

def get_champion_details(champions):
    for champ in champions:
        response = requests.get(f'https://ddragon.leagueoflegends.com/cdn/16.6.1/data/en_US/champion/{champ}.json').json()
        save_data_to_s3(response, 'champion_details')

acc_id = get_account()
get_mastery(acc_id)
matches_list = get_matches_list(acc_id)
get_matches(matches_list)
# champs = get_champions()
# get_champion_details(champs)