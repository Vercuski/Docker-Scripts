"""Example DAG: runs every 5 minutes, checks that two other stacks answer on GroupNetwork, then logs a summary.
Unpause it in the UI (DAGs are created paused) or trigger it manually."""
from __future__ import annotations

from datetime import datetime, timedelta

import requests
from airflow.sdk import dag, task


@dag(
    schedule=timedelta(minutes=5),
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["example"],
)
def hello_dotnet_stack():
    @task
    def check(url: str) -> dict:
        try:
            status = requests.get(url, timeout=5).status_code
        except requests.RequestException as ex:
            status = f"unreachable ({type(ex).__name__})"
        return {"url": url, "status": status}

    @task
    def summarize(results: list[dict]) -> None:
        for r in results:
            print(f"{r['url']}: {r['status']}")

    summarize(check.expand(url=["http://airflow:8080/api/v2/monitor/health", "http://temporal-ui:8080/"]))


hello_dotnet_stack()
