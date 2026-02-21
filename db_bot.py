import json
from google import genai
import os
import sqlite3
from time import time

print("Running db_bot.py!")

fdir = os.path.dirname(__file__)
def getPath(fname):
    return os.path.join(fdir, fname)

# SQLITE
sqliteDbPath = getPath("aidb.sqlite")
setupSqlPath = getPath("setup.sql")
setupSqlDataPath = getPath("setupData.sql")

# Erase previous db
if os.path.exists(sqliteDbPath):
    os.remove(sqliteDbPath)

# create new db
sqliteCon = sqlite3.connect(sqliteDbPath) 
sqliteCursor = sqliteCon.cursor()
sqliteCursor.execute("PRAGMA foreign_keys = ON")

# read in setup files
with (
        open(setupSqlPath) as setupSqlFile,
        open(setupSqlDataPath) as setupSqlDataFile
    ):

    setupSqlScript = setupSqlFile.read()
    setupSQlDataScript = setupSqlDataFile.read()

# execute setup files
sqliteCursor.executescript(setupSqlScript) # setup tables and keys
sqliteCursor.executescript(setupSQlDataScript) # setup tables and keys

def runSql(query):
    result = sqliteCursor.execute(query).fetchall()
    return result

# GEMINI
chosen_model = "gemini-3.1-pro-preview"

client = genai.Client()

def getGeminiResponse(content):
    response = client.models.generate_content(model=chosen_model, contents=content)
    return response.text


# strategies
commonSqlOnlyRequest = """
 Give me a SQLite SELECT statement that answers the question. Respond only with the SQL query, no explanations, no code blocks, no markdown.
 """
strategies = {
    "zero_shot": setupSqlScript + commonSqlOnlyRequest,
    "single_domain_single_shot": (setupSqlScript +
                   " Example: Who has a season pass? " +
                   " Return: SELECT \nCustomer.First_name, \nCustomer.Last_name \nFROM \nCustomer \nJOIN \nSeason_pass ON Customer.id = Season_pass.CustomerId; " +
                   commonSqlOnlyRequest)
}

questions = [
    "Who has a reservation in October of 2023?",
    "Can Donald go to disneyland on Christmas?",
    "Does Daisy qualify for the so-cal discount?",
    "I want to email everyone who has an inspire key for an upgrade deal. Can you give me all their emails?",
    "List the names and emails of customers who live in California.",
    "Are there any blackout dates for the 'Inspire Key' pass type?"
]


# use the markdown for the sql syntax to find the SQL query
def sanitizeForJustSql(value):
    value = value.strip()
    
    # Check for specific SQL code blocks
    for marker in ["```sql", "```sqlite", "```"]:
        if marker in value:
            # Split at the marker and take everything after it
            parts = value.split(marker, 1)
            if len(parts) > 1:
                code_block = parts[1]
                # Find the end marker
                end_marker = code_block.find("```")
                if end_marker != -1:
                    sql = code_block[:end_marker].strip()
                else:
                    sql = code_block.strip()
                # Remove language specifier if present
                if "\n" in sql:
                    lines = sql.split("\n", 1)
                    if lines[0].lower() in ["sql", "sqlite"]:
                        sql = lines[1]
                return sql.strip()
    
    # If no code blocks, assume the response is pure SQL
    # But try to extract if it starts with SELECT
    if value.upper().startswith("SELECT"):
        return value
    else:
        # Fallback: return as is, but this might not be SQL
        return value

for strategy in strategies:
    responses = {"strategy": strategy, "prompt_prefix": strategies[strategy]}
    questionResults = []
    print("########################################################################")
    print(f"Running strategy: {strategy}")
    for question in questions:

        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        print("Question:")
        print(question)
        error = "None"
        sqlSyntaxResponse = ""
        friendlyResponse = ""
        queryRawResponse = ""
        try:
            getSqlFromQuestionEngineeredPrompt = strategies[strategy] + " " + question
            sqlSyntaxResponse = getGeminiResponse(getSqlFromQuestionEngineeredPrompt)
            sqlSyntaxResponse = sanitizeForJustSql(sqlSyntaxResponse)
            print("SQL Syntax Response:")
            print(sqlSyntaxResponse)
            queryRawResponse = str(runSql(sqlSyntaxResponse))
            print("Query Raw Response:")
            print(queryRawResponse)

            # TODO this prompt is insufficient. ChatGPT doesn't have all the context that it needs.
            # What context would help the friendly response be more successful? Can you fix it?
            friendlyResultsPrompt = "I asked a question \"" + question +"\" and the response was \""+queryRawResponse+"\" Please, just give a concise response in a more friendly way? Please do not give any other suggests or chatter."
            friendlyResponse = getGeminiResponse(friendlyResultsPrompt)
            print("Friendly Response:")
            print(friendlyResponse)
        except Exception as err:
            error = str(err)
            print(err)

        questionResults.append({
            "question": question,
            "sql": sqlSyntaxResponse,
            "queryRawResponse": queryRawResponse,
            "friendlyResponse": friendlyResponse,
            "error": error
        })

    responses["questionResults"] = questionResults

    with open(getPath(f"response_{strategy}_{time()}.json"), "w") as outFile:
        json.dump(responses, outFile, indent = 2)


sqliteCursor.close()
sqliteCon.close()
print("Done!")
