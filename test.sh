kl=$(kitchen list | cut -d' ' -f1 | sed 1d | grep "$BOX" | sed 's/^outlyer-agent-//')
for i in $kl; do printf '%-15s\n' "$i"; done | parallel --gnu -j3 --plus --tag echo slot:{%} job:{\#}/{= '$_=total_jobs()' =} \&\& kitchen test outlyer-agent-{= s: +:: =}
