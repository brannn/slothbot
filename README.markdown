## slothbot-muc

A collection of scripts you can use to monitor your Apache servers for long-running client connections and then put the data onto a Beanstalkd tube where the Jabber bot can grab them and notify a MUC.


### Requirements

- A Beanstalkd server
- beanstalk-client (Ruby)
- Beanstalk::Client (Perl)
- Parse::Apache::ServerStatus::Extended (Perl) 
- An XMPP server

### Getting started

1. Edit 'hosts.dat' to include the Apache servers you want to monitor.
2. Modify 'slothbot.yml' with your Jabber credentials and Beanstalkd info.
3. Modify $port in 'check_sloth.pl' to reflect your environment. 
4. Run 'start.sh'
5. Now run 'check_sloth.pl'
6. When it works to your satisfaction, throw 'check_sloth.pl' into a crontab.

