import http
import datetime
import util
import oauth_base

class Error(Exception):
	"""Exceptions"""

def login():
	oauth_base.delete_file()
	refresh_token(None)

def refresh_token(auth):
	content = http.req_json('GET',
		'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token',
		headers = { 'Metadata-Flavor': 'Google' })
	now = int((datetime.datetime.now() - datetime.datetime(1970,1,1)).total_seconds())
	expires_in = content['expires_in']
	content['created'] = now
	content['expires'] = now + expires_in
	content['handler'] = 'gce'
	oauth_base.write_file(content)

def argparse_prepare(sub):
	""" ok """

def argparse_exec(args):
	login()
