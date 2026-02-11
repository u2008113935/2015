# Script to Analyze SQL Requirements

import sqlparse

class SQLAnalyzer:
    def __init__(self, sql_queries):
        self.sql_queries = sql_queries

    def analyze(self):
        for query in self.sql_queries:
            formatted_query = sqlparse.format(query, reindent=True, keyword_case='upper')
            print("Analyzing Query:")
            print(formatted_query)
            print("Length of Query:", len(query))
            print("---")

if __name__ == '__main__':
    queries = [
        "SELECT * FROM users WHERE age > 30;",
        "INSERT INTO users (name, age) VALUES ('John', 25);",
        "UPDATE users SET age = age + 1 WHERE name = 'Jane';"
    ]
    analyzer = SQLAnalyzer(queries)
    analyzer.analyze()