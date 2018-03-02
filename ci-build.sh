cp .kitchen.yml .kitchen.local.yml
sed -i "s/XXX-XXX-XXX-XXX-XXX/$AGENT_KEY/" .kitchen.local.yml

kitchen converge $BOX -c=10 -p -l=WARN
