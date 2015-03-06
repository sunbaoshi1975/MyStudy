## Cloud Computing Programming Assignment (MP1)
### Implementation Membership Protocol
This MP (Machine Programming assignment) requires to develop a membership protocol, preferably GOSSIP or SWIM. I implemented GOSSIP for the assignment submission and will try SWIM protocol later.
The program is written in C++ on Linux, tested on Koding.com free VM. Although the code was marked full score (90 out of 90), there are many improvement spaces. Some of them are:
* Vector is not the best data structure to store member list. I think map will be better. 
* In addition, I'd like to use a consecutive and compact memory along with the map structure to speed up multicast message assembling
* No lock on member list, which could lead the program erratic behaviours
* Better add Tfail flag in member entry, now I'm using -(heartbeat) to mark a failed node and abs() when comparing with received data. It works but a bit weird, right?
* Basically I only implemented push mode GOSSIP, want to add pull mode and make a comparison regarding efficiency 
* Some code usable but not fit well with the grading system, I commented them out to pass the submission
* Give the tight time, code is ugly, sorry
