import os

from azure.ai.ml import Input, dsl, load_component


def build_credit_defaults_pipeline(ml_client):
    src_dir = "src"

    # Loading the component from the yml file
    data_prep_component = load_component(source=f"{src_dir}/components/data_prep/data_prep.yaml")
    train_component = load_component(source=f"{src_dir}/components/train/train.yaml")

    # Register the component to the workspace
    data_prep_component = ml_client.create_or_update(data_prep_component)
    train_component = ml_client.create_or_update(train_component)

    @dsl.pipeline(
        compute="serverless",
        description="E2E data_perp-train pipeline",
    )
    def credit_defaults_pipeline(
        pipeline_job_data_input,
        pipeline_job_test_train_ratio,
        pipeline_job_learning_rate,
        pipeline_job_registered_model_name,
    ):
        data_prep_job = data_prep_component(
            data=pipeline_job_data_input,
            test_train_ratio=pipeline_job_test_train_ratio,
        )

        train_component(
            train_data=data_prep_job.outputs.train_data,
            test_data=data_prep_job.outputs.test_data,
            learning_rate=pipeline_job_learning_rate,
            registered_model_name=pipeline_job_registered_model_name,
        )

        return {
            "pipeline_job_train_data": data_prep_job.outputs.train_data,
            "pipeline_job_test_data": data_prep_job.outputs.test_data,
        }

    data_asset = ml_client.data.get(
        name=os.environ["DATASET_NAME"],
        version=os.environ["DATASET_VERSION"],
    )

    return credit_defaults_pipeline(
        pipeline_job_data_input=Input(type="uri_file", path=data_asset.path),
        pipeline_job_test_train_ratio=float(os.environ["TEST_TRAIN_RATIO"]),
        pipeline_job_learning_rate=float(os.environ["LEARNING_RATE"]),
        pipeline_job_registered_model_name=os.environ["REGISTERED_MODEL_NAME"],
    )
