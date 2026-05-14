from pymongo import MongoClient
from app.config.settings import MONGO_URL

client = MongoClient(MONGO_URL)

db = client["data_center"]

client_profiles = db["client_profiles"]

organization_profiles = db["organization_profiles"]

notifications = db["notifications"]

categories = db["categories"]

servers = db["servers"]