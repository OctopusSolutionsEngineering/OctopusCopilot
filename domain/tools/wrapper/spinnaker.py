def spinnaker_wrapper(query, callback, logging):
    def migrate_spinnaker_pipeline(spinnaker_json=None, **kwargs):
        """Responds to prompts about migrating, converting, or translating Spinnaker pipeline JSON
        to Octopus Deploy. Use this function when the query involves Spinnaker pipeline migration.
        Example prompts include:
        * Migrate this Spinnaker pipeline JSON to Octopus Deploy
        * Convert the following Spinnaker pipeline to an Octopus project
        * Translate this Spinnaker JSON to Octopus Deploy configuration
        * Map this Spinnaker deploy stage to Octopus Deploy steps

        You will be penalized for selecting this function when the query does not mention
        Spinnaker or the migration of Spinnaker pipeline configuration.

        Args:
            spinnaker_json: The Spinnaker pipeline JSON to migrate, if provided in the query
        """

        if logging:
            logging("Enter:", "migrate_spinnaker_pipeline")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", f"Value: {value}")

        return callback(query, spinnaker_json)

    return migrate_spinnaker_pipeline

