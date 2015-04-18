/**********************************
 * FILE NAME: MP1Node.cpp
 *
 * DESCRIPTION: Membership protocol run by this Node.
 * 				Definition of MP1Node class functions.
 **********************************/

#include "MP1Node.h"

/*
 * Note: You can change/add any functions in MP1Node.{h,cpp}
 */

/**
 * Overloaded Constructor of the MP1Node class
 * You can add new members to the class if you think it
 * is necessary for your logic to work
 */
MP1Node::MP1Node(Member *member, Params *params, EmulNet *emul, Log *log, Address *address) {
	for( int i = 0; i < 6; i++ ) {
		NULLADDR[i] = 0;
	}
	this->memberNode = member;
	this->emulNet = emul;
	this->log = log;
	this->par = params;
	this->memberNode->addr = *address;
}

/**
 * Destructor of the MP1Node class
 */
MP1Node::~MP1Node() {}

/**
 * FUNCTION NAME: recvLoop
 *
 * DESCRIPTION: This function receives message from the network and pushes into the queue
 * 				This function is called by a node to receive messages currently waiting for it
 */
int MP1Node::recvLoop() {
    if ( memberNode->bFailed ) {
    	return false;
    }
    else {
    	return emulNet->ENrecv(&(memberNode->addr), enqueueWrapper, NULL, 1, &(memberNode->mp1q));
    }
}

/**
 * FUNCTION NAME: enqueueWrapper
 *
 * DESCRIPTION: Enqueue the message from Emulnet into the queue
 */
int MP1Node::enqueueWrapper(void *env, char *buff, int size) {
	Queue q;
	return q.enqueue((queue<q_elt> *)env, (void *)buff, size);
}

/**
 * FUNCTION NAME: nodeStart
 *
 * DESCRIPTION: This function bootstraps the node
 * 				All initializations routines for a member.
 * 				Called by the application layer.
 */
void MP1Node::nodeStart(char *servaddrstr, short servport) {
    Address joinaddr;
    joinaddr = getJoinAddress();

    // Self booting routines
    if( initThisNode(&joinaddr) == -1 ) {
#ifdef DEBUGLOG
        log->LOG(&memberNode->addr, "init_thisnode failed. Exit.");
#endif
        exit(1);
    }

    if( !introduceSelfToGroup(&joinaddr) ) {
        finishUpThisNode();
#ifdef DEBUGLOG
        log->LOG(&memberNode->addr, "Unable to join self to group. Exiting.");
#endif
        exit(1);
    }

    return;
}

/**
 * FUNCTION NAME: initThisNode
 *
 * DESCRIPTION: Find out who I am and start up
 */
int MP1Node::initThisNode(Address *joinaddr) {
	/*
	 * This function is partially implemented and may require changes
	 */
	 
	//int id = *(int*)(&memberNode->addr.addr);
	//int port = *(short*)(&memberNode->addr.addr[4]);

	memberNode->bFailed = false;
	memberNode->inited = true;
	memberNode->inGroup = false;
    // node is up!
	memberNode->nnb = 0;
	memberNode->heartbeat = 0;
	memberNode->pingCounter = TFAIL;
	memberNode->timeOutCounter = -1;
    initMemberListTable(memberNode);

	// SBS add
	/// Add myself into list
	//memberNode->myPos
	MemberInList(&memberNode->addr, memberNode->heartbeat, true);
    return 0;
}

/**
 * FUNCTION NAME: introduceSelfToGroup
 *
 * DESCRIPTION: Join the distributed system
 */
int MP1Node::introduceSelfToGroup(Address *joinaddr) {
	MessageHdr *msg;
#ifdef DEBUGLOG
    static char s[1024];
#endif

    if ( 0 == memcmp((char *)&(memberNode->addr.addr), (char *)&(joinaddr->addr), sizeof(memberNode->addr.addr))) {
        // I am the group booter (first process to join the group). Boot up the group
#ifdef DEBUGLOG
        log->LOG(&memberNode->addr, "Starting up group...");
#endif
        memberNode->inGroup = true;		// As an introducer, acknowledge myself anyway

		// SBS added
		//memberNode->myPos = MemberInList(&memberNode->addr, memberNode->heartbeat, true);
    }
    else {
		/*
        size_t msgsize = sizeof(MessageHdr) + sizeof(joinaddr->addr) + sizeof(long) + 1;
        msg = (MessageHdr *) malloc(msgsize * sizeof(char));

        // create JOINREQ message: format of data is {struct Address myaddr} + {1 byte separator} + {heartbeat}   // SBS added
        msg->msgType = JOINREQ;
        memcpy((char *)(msg+1), &memberNode->addr.addr, sizeof(memberNode->addr.addr));
        memcpy((char *)(msg+1) + 1 + sizeof(memberNode->addr.addr), &memberNode->heartbeat, sizeof(long));
		*/
		size_t msgsize = sizeof(MessageHdr);
		msg = (MessageHdr *) malloc(msgsize * sizeof(char));
		msg->msgType = JOINREQ;
		memcpy(msg->_addr, &(memberNode->addr.addr), sizeof(memberNode->addr.addr));
		msg->_pad = 0;		// No message body
		msg->_heartbeat = ++memberNode->heartbeat;
#ifdef DEBUGLOG
        sprintf(s, "Trying to join...");
        log->LOG(&memberNode->addr, s);
#endif

        // send JOINREQ message to introducer member
        emulNet->ENsend(&memberNode->addr, joinaddr, (char *)msg, msgsize);

        free(msg);
    }

    return 1;

}

/**
 * FUNCTION NAME: finishUpThisNode
 *
 * DESCRIPTION: Wind up this node and clean up state
 */
int MP1Node::finishUpThisNode(){
   /*
    * Your code goes here
    */
	// SBS add
	/// Change Status, send 'REMOVEREQ' message (not necessary, but graceful) and remove from list
	memberNode->bFailed = true;
	memberNode->inGroup = false;
	//memberNode->memberList[]
	//memberNode->myPos->settimestamp(0);
	
	//MemberOutList(&memberNode->addr);
	char lv_addr[6];
	Address ndAddr;
	int nLoop;
	int nCnt = memberNode->memberList.size();
	MemberListEntry lv_Item;
	int id = 0;
	short port = 0;
	
	id = *(int *)(&memberNode->addr.addr);
	port = *(short *)(&memberNode->addr.addr[4]);
	
	/*
	for( nLoop = 0; nLoop < nCnt; nLoop++ )
	{
		lv_Item = memberNode->memberList.at(nLoop);
		//if( lv_Item.getid() == id && lv_Item.getport() == port )
		//	continue;

		*(int *)(&lv_addr) = lv_Item.getid();
		*(short *)(&lv_addr[4]) = lv_Item.getport();
		memcpy(&ndAddr.addr, &lv_addr, sizeof(ndAddr.addr));
		log->logNodeRemove(&memberNode->addr, &ndAddr);
	}	
	memberNode->memberList.clear();*/
	//log->logNodeRemove(&memberNode->addr, &memberNode->addr);
	
	return 0;
}
/**
 * FUNCTION NAME: nodeLoop
 *
 * DESCRIPTION: Executed periodically at each member
 * 				Check your messages in queue and perform membership protocol duties
 */
void MP1Node::nodeLoop() {
    if (memberNode->bFailed) {
    	return;
    }

    // Check my messages
    checkMessages();

    // Wait until you're in the group...
    if( !memberNode->inGroup ) {
    	return;
    }

    // ...then jump in and share your responsibilites!
    nodeLoopOps();

    return;
}

/**
 * FUNCTION NAME: checkMessages
 *
 * DESCRIPTION: Check messages in the queue and call the respective message handler
 */
void MP1Node::checkMessages() {
    void *ptr;
    int size;

    // Pop waiting messages from memberNode's mp1q
    while ( !memberNode->mp1q.empty() ) {
    	ptr = memberNode->mp1q.front().elt;
    	size = memberNode->mp1q.front().size;
    	memberNode->mp1q.pop();
    	recvCallBack((void *)memberNode, (char *)ptr, size);
    }
    return;
}

/**
 * FUNCTION NAME: recvCallBack
 *
 * DESCRIPTION: Message handler for different message types
 */
bool MP1Node::recvCallBack(void *env, char *data, int size ) {
	/*
	 * Your code goes here
	 */
	// SBS added
#ifdef DEBUGLOG
    static char s[1024];
#endif
	
	MessageHdr *sndmsg;
	Member *lv_Node = (Member *)env;
	static size_t msgsize = sizeof(MessageHdr);
	char strAddr[30];
	Address ndAddr;
	int nItemCount = 0;
	int nActualItemCount = 0;
	long datalength = 0;
	if (size >= (int)msgsize ) {
		MessageHdr *msg = (MessageHdr *)data;
		//pndAddr = new Address((string)msg->_addr);
		memcpy(&ndAddr.addr, &msg->_addr, sizeof(ndAddr.addr));
		stringAddress(strAddr, &ndAddr);
		//cout<<msg->msgType<<" msg received from: "<<strAddr<<" to: "<<lv_Node->addr.getAddress() << endl;
		switch( msg->msgType ) {
			case JOINREQ:
#ifdef DEBUGLOG
				sprintf(s, "Received JOINREQ message from: %s", strAddr);
		//		log->LOG(&lv_Node->addr, s);
		//		cout<<s<< endl;
#endif
				// Add message peer into list (trust it has the newest data about itself)
				MemberInList(&ndAddr, msg->_heartbeat, true);
				//log->logNodeAdd(&lv_Node->addr, &ndAddr);		// Must LOG, move to MemberInList
				
				// Send JOINREP with Local List (better exclusive the destination peer)
				/// Calculate size of list
				//nItemCount = lv_Node->memberList.size();
				nItemCount = 0;
				if (nItemCount > 1) {
					datalength = (nItemCount - 1) * sizeof(SyncItem);
				}
				else {
					datalength = 0;
				}
				sndmsg = (MessageHdr *) malloc(msgsize + datalength);
				memset(sndmsg, 0x00, msgsize + datalength);
				sndmsg->msgType = JOINREP;
				memcpy(sndmsg->_addr, &(lv_Node->addr.addr), sizeof(lv_Node->addr.addr));
				/// Message body: item list
				if (datalength > 0) {
					nActualItemCount = GetItemListString((char *)(sndmsg + msgsize), &lv_Node->addr);
					datalength = nActualItemCount * sizeof(SyncItem);
				}
				sndmsg->_pad = datalength;
				sndmsg->_heartbeat = ++memberNode->heartbeat;
				
				// Reply message
				emulNet->ENsend(&lv_Node->addr, &ndAddr, (char *)sndmsg, msgsize + datalength);
				free(sndmsg);
#ifdef DEBUGLOG
				sprintf(s, "Send JOINREP message to: %s, datalength: %d, nActualItemCount: %d, nItemCount: %d", strAddr, (int)datalength, nActualItemCount, nItemCount);
		//		log->LOG(&lv_Node->addr, s);
#endif
				break;
				
			case JOINREP:
#ifdef DEBUGLOG
				sprintf(s, "Received JOINREP message from: %s, datalength: %d, total received data size: %d", strAddr, (int)msg->_pad, size);
		//		log->LOG(&lv_Node->addr, s);
		//		cout<<s<< endl;
#endif
				// Set In Group Flag
				lv_Node->inGroup = true;	// means the introducer knows me
				
				// Add message peer into list (trust it has the newest data about itself)
				MemberInList(&ndAddr, msg->_heartbeat, false);
				
				// Update Local List, should consider both push and pull modes
				if (msg->_pad > 0) {
					UpdateLocalList((char *)(data+msgsize), msg->_pad);
				}
				break;
				
			case GOSSIP:
#ifdef DEBUGLOG
				sprintf(s, "Received GOSSIP message from: %s, datalength: %d, total received data size: %d, test: %d", strAddr, (int)msg->_pad, size, ((char *)(data+msgsize))[0]);
			//	log->LOG(&lv_Node->addr, s);
			//	cout<<s<< endl;
#endif
				// Add message peer into list
				MemberInList(&ndAddr, msg->_heartbeat, false);

				// Update Local List, should consider both push and pull modes
				if (msg->_pad > 0) {
					UpdateLocalList((char *)(data+msgsize), msg->_pad);
				}
				
				break;

			default:
#ifdef DEBUGLOG
				sprintf(s, "Unknown message received, msgType: %d from: %s", msg->msgType, strAddr);
			//	log->LOG(&lv_Node->addr, s);
#endif
				return false;
				break;
		}
		
		//delete(pndAddr);
	}
	 
	return true;
}
/**
 * FUNCTION NAME: nodeLoopOps
 *
 * DESCRIPTION: Check if any node hasn't responded within a timeout period and then delete
 * 				the nodes
 * 				Propagate your membership list
 */
void MP1Node::nodeLoopOps() {

	/*
	 * Your code goes here
	 */
	// SBS added
	if( memberNode->bFailed )
	{
		finishUpThisNode();
		return;
	}
	
	// Periodically multicast List
	//memberNode->myPos->setheartbeat(++memberNode->heartbeat);
	MulticastGossip();
		
	// Check Fail Time-out and Clean up Time-out
	CheckFailedTimeout();
	CheckCleanupTimeout();

    return;
}

// SBS added
void MP1Node::MulticastGossip()
{
#ifdef DEBUGLOG
    static char s[1024];
#endif
	
	static int lstIndex = 0;
	int nLoop;
	char *sndmsg;
	Address ndAddr;
	char strAddr[30];
	char lv_addr[6];
	static size_t msgsize = sizeof(MessageHdr);
	int nItemCount = 0;
	int nActualItemCount = 0;
	long datalength = 0;
	int id = *(int *)(&memberNode->addr.addr);
	short port = *(short *)(&memberNode->addr.addr[4]);
	int lv_nSndCnt = 0;
	MessageHdr lv_hrd;
	MemberListEntry lv_Item;

	// Prepare message
	/// Calculate size of list
	nItemCount = memberNode->memberList.size();
	if( nItemCount > 1 )
	{
		datalength = (nItemCount - 1) * sizeof(SyncItem);
	}
	else
	{
		datalength = 0;
	}
	sndmsg = (char *) malloc(msgsize + datalength);
	//sndmsg = (MessageHdr *) malloc(msgsize + datalength);
	memset(sndmsg, 0x00, msgsize + datalength);
	//sndmsg->msgType = GOSSIP;
	//memcpy(sndmsg->_addr, &(memberNode->addr.addr), sizeof(memberNode->addr.addr));
	lv_hrd.msgType = GOSSIP;
	memcpy(lv_hrd._addr, memberNode->addr.addr, sizeof(memberNode->addr.addr));
	/// Message body: item list
	if (datalength > 0) {
		nActualItemCount = GetItemListString((char *)(sndmsg + msgsize), &memberNode->addr);
		datalength = nActualItemCount * sizeof(SyncItem);
	}
	//sndmsg->_pad = datalength;
	//sndmsg->_heartbeat = memberNode->heartbeat;
	lv_hrd._pad = datalength;
	lv_hrd._heartbeat = ++memberNode->heartbeat;
	memcpy(sndmsg, (char *)&lv_hrd, msgsize);

	// partially members
	// Send message to neighbours (except myself)
	for (nLoop = 0; nLoop < nItemCount; nLoop++) {
		lstIndex = (lstIndex+nLoop) % nItemCount;
		lv_Item = memberNode->memberList.at(lstIndex);
		
		if (lv_Item.getid() == id && lv_Item.getport() == port)  {
			// Skip me
			continue;
		} else {
			*(int *)(&lv_addr) = lv_Item.getid();
			*(short *)(&lv_addr[4]) = lv_Item.getport();
			memcpy(&ndAddr.addr, &lv_addr, sizeof(ndAddr.addr));
			stringAddress(strAddr, &ndAddr);
#ifdef DEBUGLOG
			sprintf(s, "Send GOSSIP message to: %s, datalength: %d, nActualItemCount: %d, nItemCount: %d, test: %d", strAddr, (int)datalength, nActualItemCount, nItemCount, ((char *)(sndmsg + msgsize))[0]);
			//cout<<s<< endl;
			//log->LOG(&memberNode->addr, s);
#endif

			emulNet->ENsend(&memberNode->addr, &ndAddr, (char *)sndmsg, msgsize + datalength);
			lv_nSndCnt++;
			if( lv_nSndCnt >= GOSSIPNODES && GOSSIPNODES)
				break;
		}
	}
		
	free(sndmsg);
}

void MP1Node::CheckFailedTimeout()
{
	char lv_addr[6];
	Address ndAddr;
	int nLoop;
	int nCnt = memberNode->memberList.size();
	MemberListEntry lv_Item;
	int id = 0;
	short port = 0;
	
	id = *(int *)(&memberNode->addr.addr);
	port = *(short *)(&memberNode->addr.addr[4]);
	
	for( nLoop = 0; nLoop < nCnt; nLoop++ )
	{
		lv_Item = memberNode->memberList.at(nLoop);
		/*
		if( lv_Item.getid() == id && lv_Item.getport() == port )
		{
			// Update myself
			memberNode->memberList.at(nLoop).settimestamp(par->getcurrtime());
			memberNode->memberList.at(nLoop).setheartbeat(memberNode->heartbeat);
		}
		else*/
		{
			if (par->getcurrtime() - lv_Item.gettimestamp() > TFAIL && lv_Item.getheartbeat() > 0) {
				*(int *)(&lv_addr) = lv_Item.getid();
				*(short *)(&lv_addr[4]) = lv_Item.getport();
				//pndAddr = new Address((string)lv_addr);
				memcpy(&ndAddr.addr, &lv_addr, sizeof(ndAddr.addr));
				log->logNodeRemove(&memberNode->addr, &ndAddr);
				memberNode->memberList.at(nLoop).setheartbeat(-lv_Item.getheartbeat());
				//memberNode->memberList.at(nLoop).setheartbeat(0);
				//result = memberNode->memberList.erase(result);
				//delete(pndAddr);
			}
		}
	}
}

void MP1Node::CheckCleanupTimeout()
{
	char lv_addr[6];
	Address ndAddr;
	int nLoop;
	int nCnt = memberNode->memberList.size();
	MemberListEntry lv_Item;
	int id = 0;
	short port = 0;
	
	id = *(int *)(&memberNode->addr.addr);
	port = *(short *)(&memberNode->addr.addr[4]);
	
	for( nLoop = 0; nLoop < nCnt; nLoop++ )
	{
		lv_Item = memberNode->memberList.at(nLoop);
		/*
		if( lv_Item.getid() == id && lv_Item.getport() == port )
		{
			// Update myself
			memberNode->memberList.at(nLoop).settimestamp(par->getcurrtime());
			memberNode->memberList.at(nLoop).setheartbeat(memberNode->heartbeat);
		}
		else */
		{
			if (par->getcurrtime() - lv_Item.gettimestamp() > TREMOVE && lv_Item.getheartbeat() != 0)  // SBS for MP2 > 0 to != 0
			{
				*(int *)(&lv_addr) = lv_Item.getid();
				*(short *)(&lv_addr[4]) = lv_Item.getport();
				//pndAddr = new Address((string)lv_addr);
				memcpy(&ndAddr.addr, &lv_addr, sizeof(ndAddr.addr));
				log->logNodeRemove(&memberNode->addr, &ndAddr);
				//memberNode->memberList.at(nLoop).setheartbeat(-lv_Item.getheartbeat());
				memberNode->memberList.at(nLoop).setheartbeat(0);
				vector<MemberListEntry>::iterator result;
				result = memberNode->memberList.begin();
				result+=nLoop;
				memberNode->memberList.erase(result);
				break;
				//delete(pndAddr);
			}
		}
	}
}

/// forceUpdate: flag to control update under no condition, e.g. peer updates its own state
vector<MemberListEntry>::iterator MP1Node::MemberInList(Address *addr, long heartbeat, bool forceUpdate) {
	int id = *(int *)(&addr->addr);
	short port = *(short *)(&addr->addr[4]);
	long timestamp = this->par->getcurrtime();
	char strAddr[30];
	char strAddrFrom[30];
#ifdef DEBUGLOG
    static char s[1024];
#endif
	
	if (id == 0 && port == 0)
	{
#ifdef DEBUGLOG
		sprintf(s, "ignore null address - heartbeat: %d, timestamp: %d", (int)heartbeat, (int)timestamp);
		//log->LOG(&memberNode->addr, s);
		//cout<<s <<endl;
#endif
		return memberNode->memberList.begin();
	}
	
	vector<MemberListEntry>::iterator result;

	for (result = memberNode->memberList.begin(); result != memberNode->memberList.end(); ++result) {
		if (result->getid() == id && result->getport() == port)  {
			if (abs(result->getheartbeat()) < heartbeat || forceUpdate) {
				// Update item
				result->setheartbeat(heartbeat);
				result->settimestamp(timestamp);
				if ( forceUpdate ) {
					log->logNodeAdd(&memberNode->addr, addr);
				}
			}
			return result;		// No need update because existing item is newer
		}
	}
	
	// Insert item
	//MemberListEntry lv_myLE(id, port, heartbeat, timestamp);
	MemberListEntry lv_myLE;
	lv_myLE.setid(id);
	lv_myLE.setport(port);
	lv_myLE.setheartbeat(heartbeat);
	lv_myLE.settimestamp(timestamp);
	stringAddress(strAddr, &memberNode->addr);
	stringAddress(strAddrFrom, addr);
		
#ifdef DEBUGLOG
	sprintf(s, "Item added into %s, - addr: %s, heartbeat: %d, timestamp: %d", strAddr, strAddrFrom, (int)heartbeat, (int)timestamp);
	//log->LOG(&memberNode->addr, s);
	//cout<<s<<endl;
#endif
	
	memberNode->memberList.push_back(lv_myLE);
	result = memberNode->memberList.end() - 1;
	log->logNodeAdd(&memberNode->addr, addr);
	//memberNode->nnb = memberNode->memberList.size();
	
	/*
	if (memberNode->addr == addr) {
		memberNode->myPos = memberNode->memberList.back();
	}*/
	return result;
}

bool MP1Node::MemberOutList(Address *addr) {
	if (memberNode->memberList.empty()) {
		return false;
	}

	int id = *(int *)(&addr->addr);
	short port = *(short *)(&addr->addr[4]);

	vector<MemberListEntry>::iterator result;

	for (result = memberNode->memberList.begin(); result != memberNode->memberList.end(); ++result) {
		if (result->getid() == id && result->getport() == port)  {
			memberNode->memberList.erase(result);
			log->logNodeRemove(&memberNode->addr, addr);
			//memberNode->nnb = memberNode->memberList.size();
			return true;
		}
	}
	
	return false;
}

// Return the number of copied items
int MP1Node::GetItemListString(char *msg, Address *exclusive)
{
	if (memberNode->memberList.empty()) {
		return 0;
	}

#ifdef DEBUGLOG
    static char s[1024];
#endif
	
	int nItems = 0;
	int id = 0;
	short port = 0;
	SyncItem itemData;
	if (exclusive)
	{
		id = *(int *)(&exclusive->addr);
		port = *(short *)(&exclusive->addr[4]);
	}

	nItems = 0;
	/*
	vector<MemberListEntry>::iterator result;

	for (result = memberNode->memberList.begin(); result != memberNode->memberList.end(); ++result) {
		if (exclusive)
		{
			if (result->getid() == id && result->getport() == port)  {
				// jump over this item
				continue;
			}
		}
		
		// copy an item
		try {
			memset(&itemData, 0x00, sizeof(itemData));
			*(int *)(&itemData._addr) = result->getid();
			*(short *)(&itemData._addr[4]) = result->getport();
			itemData._heartbeat = result->getheartbeat();
			memcpy((char *)(msg + nItems * sizeof(SyncItem)), &itemData, sizeof(SyncItem));
			nItems++;
		} catch(...)
		{
			return 0;
		}
	}
	*/
	int nLoop;
	int nCnt = memberNode->memberList.size();
	int getID;
	short getPort;
	MemberListEntry lv_Item;
	for( nLoop = 0; nLoop < nCnt; nLoop++ )
	{
		lv_Item = memberNode->memberList.at(nLoop);
		getID = lv_Item.getid();
		getPort = lv_Item.getport();
		if( getID == 0 && getPort == 0 )
		{
#ifdef DEBUGLOG
			sprintf(s, "error Item in list, index = %d", nLoop);
		//	log->LOG(&memberNode->addr, s);
		//	cout<<s<<endl;
#endif
			continue;
		}
		
		if (exclusive)
		{
			if (getID == id && getPort == port)  {
				// jump over this item
				continue;
			}
		}
		
		if( lv_Item.getheartbeat() > 0 )
		{
		// copy an item
			memset(&itemData, 0x00, sizeof(itemData));
			//*(int *)(&itemData._addr[0]) = lv_Item.getid();
			//*(short *)(&itemData._addr[4]) = lv_Item.getport();
			memcpy(&itemData._addr[0], &getID, sizeof(int));
			memcpy(&itemData._addr[4], &getPort, sizeof(short));
			itemData._heartbeat = lv_Item.getheartbeat();
#ifdef DEBUGLOG
			sprintf(s, "Debug sending item data: index = %d, Addr(id: %d , port: %d - [%d] [%d] [%d] [%d] [%d] [%d])", nLoop, getID, getPort, itemData._addr[0], itemData._addr[1], itemData._addr[2], itemData._addr[3], itemData._addr[4], itemData._addr[5]);
			
		//	log->LOG(&memberNode->addr, s);
#endif
			memcpy((char *)(msg + nItems * sizeof(SyncItem)), (char *)&itemData, sizeof(SyncItem));
			nItems++;
		}
	}
	
	return nItems;
}

int MP1Node::UpdateLocalList(char *msg, long length)
{
	static size_t itemSize = sizeof(SyncItem);
		
	if (length < (long)itemSize )
		return 0;

	
	int nItemCount = 0;
	int nloop;
	SyncItem *itemData;
	Address ndAddr;
#ifdef DEBUGLOG
	//char strAddr[30];
    static char s[1024];
#endif
	
	// Scan all received item data
	nItemCount = length / itemSize;
	for (nloop = 0; nloop < nItemCount; nloop++)
	{
		//memcpy(&itemData, (char *)(msg + nloop * itemSize), itemSize);
		//pndAddr = new Address((string)itemData._addr);
		//memcpy(&ndAddr.addr, &itemData._addr, sizeof(ndAddr.addr));
		//MemberInList(&ndAddr, itemData._heartbeat, false);		// Update only bigger or new
		//delete(pndAddr);
		
		itemData = (SyncItem *)(msg + nloop * itemSize);
		memcpy(ndAddr.addr, itemData->_addr, 6);
#ifdef DEBUGLOG
		//stringAddress(strAddr, &memberNode->addr);
		int id = 0;
		short port;
		memcpy(&id, &itemData->_addr[0], sizeof(int));
		memcpy(&port, &itemData->_addr[4], sizeof(short));
		sprintf(s, "UpdateLocalList interpreted an item index = %d, Addr(id: %d , port: %d - [%d] [%d] [%d] [%d] [%d] [%d])", nloop, id, port, itemData->_addr[0], itemData->_addr[1], itemData->_addr[2], itemData->_addr[3], itemData->_addr[4], itemData->_addr[5]);
		//log->LOG(&memberNode->addr, s);
		sprintf(s, "raw data - [%d] [%d] [%d] [%d] [%d] [%d]", msg[0], msg[1], msg[2], msg[3], msg[4], msg[5]);
		//log->LOG(&memberNode->addr, s);
#endif
		
		MemberInList(&ndAddr, itemData->_heartbeat, false);		// Update only bigger or new
	}

	return nItemCount;
}
/**
 * FUNCTION NAME: isNullAddress
 *
 * DESCRIPTION: Function checks if the address is NULL
 */
int MP1Node::isNullAddress(Address *addr) {
	return (memcmp(addr->addr, NULLADDR, 6) == 0 ? 1 : 0);
}

/**
 * FUNCTION NAME: getJoinAddress
 *
 * DESCRIPTION: Returns the Address of the coordinator
 */
Address MP1Node::getJoinAddress() {
    Address joinaddr;

    memset(&joinaddr, 0, sizeof(Address));
    *(int *)(&joinaddr.addr) = 1;
    *(short *)(&joinaddr.addr[4]) = 0;

    return joinaddr;
}

/**
 * FUNCTION NAME: initMemberListTable
 *
 * DESCRIPTION: Initialize the membership list
 */
void MP1Node::initMemberListTable(Member *memberNode) {
	memberNode->memberList.clear();
}

/**
 * FUNCTION NAME: printAddress
 *
 * DESCRIPTION: Print the Address
 */
void MP1Node::printAddress(Address *addr)
{
    printf("%d.%d.%d.%d:%d \n",  addr->addr[0],addr->addr[1],addr->addr[2],
                                                       addr->addr[3], *(short*)&addr->addr[4]) ;    
}

char *MP1Node::stringAddress(char *strAddr, Address *addr)
{
	if (strAddr == NULL) {
		return NULL;
	}
	
	sprintf(strAddr, "%d.%d.%d.%d:%d",  addr->addr[0],addr->addr[1],addr->addr[2],
                                                      addr->addr[3], *(short*)&addr->addr[4]);
	return strAddr;
}
