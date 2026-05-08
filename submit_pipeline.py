import os
import argparse

from dotenv import load_dotenv
from azure.ai.ml import MLClient
from azure.identity import DefaultAzureCredential

from src.pipeline.credit_card_model_train import build_credit_defaults_pipeline

load_dotenv()
PIPELINES = {
    "credit_card_model_train": build_credit_defaults_pipeline,
}


def main():
    parser = argparse.ArgumentParser(description="Submit AML pipeline")
    parser.add_argument(
        "--pipeline",
        type=str,
        required=True,
        choices=PIPELINES.keys(),
        help="Name of the pipeline to submit",
    )
    args = parser.parse_args()

    # Get ML client
    credential = DefaultAzureCredential()
    ml_client = MLClient(
        credential=credential,
        subscription_id=os.environ["AZURE_SUBSCRIPTION_ID"],
        resource_group_name=os.environ["AZURE_RESOURCE_GROUP"],
        workspace_name=os.environ["AZURE_WORKSPACE_NAME"],
    )

    # Build and submit pipeline
    pipeline = PIPELINES[args.pipeline](ml_client)
    pipeline_job = ml_client.jobs.create_or_update(
        pipeline,
        experiment_name="e2e_registered_components",
    )
    print(f"Pipeline job submitted: {pipeline_job.name}")
    ml_client.jobs.stream(pipeline_job.name)


if __name__ == "__main__":
    main()
