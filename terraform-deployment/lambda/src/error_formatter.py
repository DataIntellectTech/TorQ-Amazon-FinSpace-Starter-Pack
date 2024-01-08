import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logging.info(event)
    
    eventKeys = event.keys()
    #gaurd 1
    if 'Error' not in eventKeys or 'Cause' not in eventKeys :
        logging.error("event payload is not correct. Excpected \'Error\' and \'Cause\' within event keys")
        raise ValueError("event payload is not correct. Excpected \'Error\' and \'Cause\' within event keys")
        

    parseMessage = ""
    if isinstance(event['Cause'],str):
        parseMessage = json.loads(event['Cause'])
    elif isinstance(event['Cause'],dict):
        parseMessage = event['Cause']

    try:
        parseMessage = parseMessage['errorMessage']
    except KeyError:
        logging.warn("Expected event payload to contain \'errorMessage\' inside \'Cause\'")
        pass

    formattedMessage = f"time: {datetime.now()}. RDB/WDB scaling during Lambda Invocation failed due to the following error : {parseMessage}"
    logging.info(formattedMessage)
    
    return {
        'statusCode': 200,
        'Message': formattedMessage
    }
