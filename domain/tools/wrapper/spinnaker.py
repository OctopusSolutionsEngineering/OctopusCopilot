def spinnaker_wrapper(query, callback, logging):
    def migrate_spinnaker_pipeline(**kwargs):
        """
        Select the migrate_spinnaker_pipeline tool for prompts about recreating, migrating, converting, or translating Spinnaker pipeline JSON
        with a generated prompt to create Octopus projects.

        You MUST use the migrate_spinnaker_pipeline tool when the query involves Spinnaker pipeline migration or any prompt that
        includes instructions on generating a prompt from a Spinnaker pipeline JSON.

        Example prompts include:

        * Migrate this Spinnaker pipeline JSON to Octopus Deploy
        * Convert the following Spinnaker pipeline to an Octopus project
        * Translate this Spinnaker JSON to Octopus Deploy configuration
        * Map this Spinnaker deploy stage to Octopus Deploy steps
        * Given the sample Spinnaker pipeline JSON, generate a prompt that recreates the project in Octopus Deploy.

        The prompt will then provide additional instructions and sample Spinnaker pipeline configuration JSON.
        """

        if logging:
            logging("Enter:", "migrate_spinnaker_pipeline")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", f"Value: {value}")

        return callback(query)

    return migrate_spinnaker_pipeline
