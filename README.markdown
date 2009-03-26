## slothbot-muc

A collection of scripts you can use to monitor your Apache servers for long-running client connections and then put the data onto a Beanstalkd tube where the Jabber bot can grab them and notify a MUC.


### Requirements


- A Beanstalkd server
- beanstalk-client (Ruby)
- Beanstalk::Client (Perl)
- Parse::Apache::ServerStatus::Extended (Perl) 
- An XMPP server

### Getting started

1. Edit <code>hosts.dat</code> to include the Apache servers you want to monitor.
2. Modify <code>slothbot.yml</code> with your Jabber credentials and Beanstalkd info.
3. Modify $port in <code>check_sloth.pl</code> to reflect your environment. 
4. Run <code>start.sh</code>
5. Now run <code>check_sloth.pl</code>
6. When it works to your satisfaction, throw <code>check_sloth.pl</code> into a crontab.


>> Slothbot 15:10
   ☂ 21 slothfuls older than 5 secs on www29.foo.com:8000
