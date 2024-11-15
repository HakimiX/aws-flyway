import logging
import warnings
from urllib3.exceptions import InsecureRequestWarning
from src.utils.config import LOG_LEVEL

if logging.getLogger().hasHandlers():
    logging.getLogger().setLevel(LOG_LEVEL)
else:
    logging.basicConfig(level=LOG_LEVEL)

# ignore warning
warnings.simplefilter('ignore', InsecureRequestWarning)


logger = logging.getLogger()