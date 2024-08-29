import re

from presidio_analyzer import AnalyzerEngine
from presidio_analyzer.nlp_engine import NlpEngineProvider
from presidio_anonymizer import AnonymizerEngine

from domain.sanitizers.stringlifier.api import Stringlifier
from domain.validation.argument_validation import ensure_string

sensitive_vars = [
    "[Aa][Pp][Ii]-[A-Za-z0-9]+",
    "xoxe.[A-Za-z0-9-]+",
]
# From https://github.com/adobe/stringlifier with some minor modifications to work with the latest
# versions of numpy.
stringlifier = Stringlifier()


def create_analyser():
    # Create configuration containing engine name and models
    configuration = {
        "nlp_engine_name": "spacy",
        "models": [{"lang_code": "en", "model_name": "en_core_web_md"}],
    }
    provider = NlpEngineProvider(nlp_configuration=configuration)
    nlp_engine = provider.create_engine()
    analyzer = AnalyzerEngine(nlp_engine=nlp_engine, supported_languages=["en"])
    return analyzer


analyzer = create_analyser()
anonymizer = AnonymizerEngine()


def sanitize_message(message):
    """
    Strip sensitive and PII information from a message
    :param message: The message to be logged
    :return: The sanitized message
    """

    if not message:
        return message

    # A defensive move to stop API keys from appearing in logs
    for sensitive_var in sensitive_vars:
        message = re.sub(sensitive_var, "*****", message)

    return message


def anonymize_message(message):
    """
    Anonymize the message
    :param message: The message to be anonymized
    :return: The anonymized message
    """
    ensure_string(message, "message must be a string (anonymize_message)")

    results = analyzer.analyze(text=message, language="en")
    anonymized_text = anonymizer.anonymize(text=message, analyzer_results=results).text
    stringlifier_text = stringlifier(anonymized_text)

    return stringlifier_text[0]
