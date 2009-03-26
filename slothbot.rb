#!/usr/bin/env ruby

require 'rubygems'
require 'beanstalk-client'
require 'xmpp4r'
require 'xmpp4r/muc'

CONF_PATHS = [ "/home/bot/etc/slothbot.yml", "slothbot.yml" ]

CONF_PATH = CONF_PATHS.detect { |f| File.exist? f }

unless CONF_PATH
  puts "Expected a config in one of\n\t#{CONF_PATHS.join("\n\t")}"
  exit 1
end

CONF = YAML.load_file CONF_PATH

BEANSTALK = Beanstalk::Pool.new [CONF['beanstalk']['server']]
BEANSTALK.watch CONF['beanstalk']['tube']
BEANSTALK.ignore 'default'

TIMEOUT = CONF['beanstalk']['timeout'].to_i

client = Jabber::Client.new(Jabber::JID.new([CONF['xmpp']['jid']]))
client.connect
client.auth [CONF['xmpp']['pass']]
muc = Jabber::MUC::SimpleMUCClient.new(client)
muc.join(Jabber::JID.new([CONF['xmpp']['muc']]))

loop do
  job = BEANSTALK.reserve
  msg = job.body # + " jobid=" + job.id.to_s
  muc.say("☂ #{msg}")
  job.delete if job
end
