"""
Producer app writing single Order records at a time to a Kinesis Data Stream using
the PutRecord API of the Python SDK.

The Seller ID field of each Order record is being used as the partition key which
groups orders sold by the same seller by shard and by order within their respective
shard. Ordering is also being overriden via explicit use of SequenceNumberForOrdering
for each PutRecord API request to guarantee increasing sequence number per partition key.
"""
import json
import logging
import sys
import time

import boto3

from order_generator import make_order


logging.basicConfig(
  format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
  datefmt='%Y-%m-%d %H:%M:%S',
  level=logging.INFO,
  handlers=[
      logging.FileHandler("producer.log"),
      logging.StreamHandler(sys.stdout)
  ]
)


def main(args):
    logging.info('Starting PutRecord Producer')

    stream_name = args[1]

    kinesis = boto3.client('kinesis')

    # dict to maintain partition sequence numbers
    partition_sequences = {}

    while True:
        # Generate fake order data
        order = make_order()
        logging.info(f'Generated {order}')

        partition_key = order['seller_id']
        kwargs = dict(StreamName=stream_name,
                    Data=json.dumps(order).encode('utf-8'),
                    PartitionKey=partition_key)

        # if partition has a sequence number from a previous PutRecord request
        # use it to guarantee strict per partition ordering
        if partition_key in partition_sequences:
            seq_num = partition_sequences.get(partition_key)
            kwargs.update(SequenceNumberForOrdering=seq_num)

        try:
            # execute single PutRecord request and update partition sequence dict
            response = kinesis.put_record(**kwargs)
            partition_sequences[partition_key] = response['SequenceNumber']

            logging.info(f"Produced Record {response['SequenceNumber']} to Shard {response['ShardId']}")
        except Exception as e:
            logging.error({
                'message': 'Error producing record',
                'error': str(e),
                'record': order
            })

        # introduce artificial delay for demonstration and
        # visual tracking of logging
        time.sleep(0.3)


if __name__ == '__main__':
    main(sys.argv)
