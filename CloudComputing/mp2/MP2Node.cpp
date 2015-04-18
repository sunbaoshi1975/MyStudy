/**********************************
 * FILE NAME: MP2Node.cpp
 *
 * DESCRIPTION: MP2Node class definition
 **********************************/
#include "MP2Node.h"
msgTicket::msgTicket()
{
}

msgTicket::msgTicket(string msg, Address SendTo, int curr)
{
	m_msg = msg;
	toAddr = SendTo;
	nIssueTime = curr;
	bReplied = false;
	bSucc = false;
	nReplyTime = 0;
}

msgTicket::~msgTicket()
{
}

bool msgTicket::isReplied()
{
	return bReplied;
}

bool msgTicket::isRemoveTimeout(int curr)
{
	if( curr - nIssueTime > TO_REMOVE )
		return true;
	
	return false;
}

bool msgTicket::isTimeout(int curr)
{
	bool bTO = false;
	
	if( !isReplied() )
	{
		if( curr - nIssueTime > TO_REPLY )
			bTO = true;
	}
	
	return bTO;
}

bool msgTicket::isReplySucc()
{
	bool ret = false;
	
	if( isReplied() )
	{
		//Message lv_msg(m_msg);
		//ret = lv_msg.success;
		ret = bSucc;
	}
	
	return ret;
}

void msgTicket::SetReplied(bool succ, int curr)
{
	bReplied = true;
	nReplyTime = curr;
	//Message lv_msg(m_msg);
	//lv_msg.success = succ;
	//m_msg = lv_msg.toString();
	bSucc = succ;
}

msgTicket& msgTicket::operator =(const msgTicket& anyTicket) {
	this->m_msg = anyTicket.m_msg;
	this->nIssueTime = anyTicket.nIssueTime;
	this->bReplied = anyTicket.bReplied;
	this->nReplyTime = anyTicket.nReplyTime;
	this->toAddr = anyTicket.toAddr;
	this->bSucc = anyTicket.bSucc;
	this->strValue = anyTicket.strValue;

	return *this;
}

/**
 * constructor
 */
MP2Node::MP2Node(Member *memberNode, Params *par, EmulNet * emulNet, Log * log, Address * address) {
	this->memberNode = memberNode;
	this->par = par;
	this->emulNet = emulNet;
	this->log = log;
	ht = new HashTable();
	this->memberNode->addr = *address;
}

/**
 * Destructor
 */
MP2Node::~MP2Node() {
	delete ht;
	delete memberNode;
}

/**
 * FUNCTION NAME: updateRing
 *
 * DESCRIPTION: This function does the following:
 * 				1) Gets the current membership list from the Membership Protocol (MP1Node)
 * 				   The membership list is returned as a vector of Nodes. See Node class in Node.h
 * 				2) Constructs the ring based on the membership list
 * 				3) Calls the Stabilization Protocol
 */
void MP2Node::updateRing() {
	/*
	 * Implement this. Parts of it are already implemented
	 */
	vector<Node> curMemList;
	bool change = false;

#ifdef DEBUGLOG
    static char s[1024];
#endif

#ifdef DEBUGLOG
//		cout<<"updateRing()"<< endl;
#endif

	/*
	 *  Step 1. Get the current membership list from Membership Protocol / MP1
	 */
	curMemList = getMembershipList();

	/*
	 * Step 2: Construct the ring
	 */
	// Sort the list based on the hashCode
	sort(curMemList.begin(), curMemList.end());

	// SBS added for MP2
	/// Using curMemList to update ring
	int nLoop, myIndex = -1;
	int nCnt = curMemList.size();
	int nOldCnt = ring.size();
	Node lv_Node, lv_OldNode;
	
#ifdef DEBUGLOG
	//sprintf(s, "updateRing ring size = %d, new size = %d", nOldCnt, nCnt);
	//cout<<s<< endl;
	//log->LOG(&memberNode->addr, s);
#endif
	
	for( nLoop = 0; nLoop < nCnt; nLoop++ ) {
		lv_Node = curMemList.at(nLoop);
		if( lv_Node.getAddress()->getAddress() == memberNode->addr.getAddress() )
		{
			myIndex = nLoop;
#ifdef DEBUGLOG
//			sprintf(s, "updateRing myindex = %d", myIndex);
//			cout<<s<< endl;
#endif	
		}
		if(nOldCnt > nLoop) {
			lv_OldNode = ring.at(nLoop);
			if( lv_OldNode.getAddress()->getAddress() != lv_Node.getAddress()->getAddress() ) {
				ring.at(nLoop) = lv_Node;
				//change = true;
			}
		} else {
			// new list is larger
			ring.emplace_back(lv_Node);
			//change = true;
		}
	}
	// If the old list is larger, remove the rest of items
	if( nOldCnt > nCnt ) {
		ring.resize(nCnt);
		//change = true;
	}
	if( myIndex >= 0 )
	{
		/*
		hasMyReplicas.clear();
		hasMyReplicas.emplace_back(ring.at((myIndex + 1)%ring.size()));
		hasMyReplicas.emplace_back(ring.at((myIndex + 2)%ring.size()));

		haveReplicasOf.clear();
		haveReplicasOf.emplace_back(ring.at((ring.size() + myIndex - 1)%ring.size()));
		haveReplicasOf.emplace_back(ring.at((ring.size() + myIndex - 2)%ring.size()));
		*/
		Node lv_PreNode1, lv_PreNode2, lv_SuccNode1, lv_SuccNode2;
		lv_SuccNode1 = ring.at((myIndex + 1)%ring.size());
		lv_SuccNode2 = ring.at((myIndex + 2)%ring.size());
		lv_PreNode1 = ring.at((ring.size() + myIndex - 1)%ring.size());
		lv_PreNode2 = ring.at((ring.size() + myIndex - 2)%ring.size());
		
		if( hasMyReplicas.size() == 0 ) {
			hasMyReplicas.emplace_back(lv_SuccNode1);
			hasMyReplicas.emplace_back(lv_SuccNode2);
			change = true;
#ifdef DEBUGLOG
			sprintf(s, "succ neighbour changed: INIT");
			cout<<s<< endl;
			//log->LOG(&memberNode->addr, s);
#endif			
		} else {
			if( hasMyReplicas.at(0).getAddress()->getAddress() != lv_SuccNode1.getAddress()->getAddress() ) {
				hasMyReplicas.at(0) = lv_SuccNode1;
#ifdef DEBUGLOG
				sprintf(s, "succ neighbour changed: succ1");
				cout<<s<< endl;
				//log->LOG(&memberNode->addr, s);
#endif			
				change = true;
			}
			if( hasMyReplicas.at(1).getAddress()->getAddress() != lv_SuccNode2.getAddress()->getAddress() ) {
				hasMyReplicas.at(1) = lv_SuccNode2;
#ifdef DEBUGLOG
				sprintf(s, "succ neighbour changed: succ2");
				cout<<s<< endl;
				//log->LOG(&memberNode->addr, s);
#endif			
				change = true;
			}
		}

		if( haveReplicasOf.size() == 0 ) {
			haveReplicasOf.emplace_back(lv_PreNode1);
			haveReplicasOf.emplace_back(lv_PreNode2);
			change = true;
#ifdef DEBUGLOG
			sprintf(s, "pred neighbour changed: INIT");
			cout<<s<< endl;
			//log->LOG(&memberNode->addr, s);
#endif			
		} else {
			if( haveReplicasOf.at(0).getAddress()->getAddress() != lv_PreNode1.getAddress()->getAddress() ) {
				haveReplicasOf.at(0) = lv_PreNode1;
				change = true;
#ifdef DEBUGLOG
				sprintf(s, "pred neighbour changed: pred1");
				cout<<s<< endl;
				//log->LOG(&memberNode->addr, s);
#endif			
			}
			if( haveReplicasOf.at(1).getAddress()->getAddress() != lv_PreNode2.getAddress()->getAddress() ) {
				haveReplicasOf.at(1) = lv_PreNode2;
				change = true;
#ifdef DEBUGLOG
				sprintf(s, "pred neighbour changed: pred2");
				cout<<s<< endl;
				//log->LOG(&memberNode->addr, s);
#endif			
			}
		}
	}
	
	/*
	 * Step 3: Run the stabilization protocol IF REQUIRED
	 */
	// Run stabilization protocol if the hash table size is greater than zero and if there has been a changed in the ring
	// SBS added for MP2
	if( change && !ht->isEmpty() ) {
		/// Run stabilization protocol
		stabilizationProtocol();
	}
	
	// SBS added for MP2
	/// Coordinator message timeout checking
	CheckReplyMap();
}

/**
 * FUNCTION NAME: getMemberhipList
 *
 * DESCRIPTION: This function goes through the membership list from the Membership protocol/MP1 and
 * 				i) generates the hash code for each member
 * 				ii) populates the ring member in MP2Node class
 * 				It returns a vector of Nodes. Each element in the vector contain the following fields:
 * 				a) Address of the node
 * 				b) Hash code obtained by consistent hashing of the Address
 */
vector<Node> MP2Node::getMembershipList() {
	unsigned int i;
	vector<Node> curMemList;
	for ( i = 0 ; i < this->memberNode->memberList.size(); i++ ) {
		
		// SBS added for MP2
		if( this->memberNode->memberList.at(i).getheartbeat() <= 0 )
			continue;
		
		Address addressOfThisMember;
		int id = this->memberNode->memberList.at(i).getid();
		short port = this->memberNode->memberList.at(i).getport();
		memcpy(&addressOfThisMember.addr[0], &id, sizeof(int));
		memcpy(&addressOfThisMember.addr[4], &port, sizeof(short));
		curMemList.emplace_back(Node(addressOfThisMember));
	}
	return curMemList;
}

/**
 * FUNCTION NAME: hashFunction
 *
 * DESCRIPTION: This functions hashes the key and returns the position on the ring
 * 				HASH FUNCTION USED FOR CONSISTENT HASHING
 *
 * RETURNS:
 * size_t position on the ring
 */
size_t MP2Node::hashFunction(string key) {
	std::hash<string> hashFunc;
	size_t ret = hashFunc(key);
	return ret%RING_SIZE;
}

// SBS added for MP2
// coordinator dispatches messages to corresponding nodes
void MP2Node::dispatchMessages(Message message)
{
#ifdef DEBUGLOG
    static char s[1024];
#endif
	
	vector<Node> repList = findNodes(message.key);
	if( repList.size() < 3 )
	{
		// updateRing() error!
#ifdef DEBUGLOG
		sprintf(s, "dispatchMessages failed to find replicas for key %s", message.key.c_str());
		cout<<s<< endl;
#endif
		return;
	}

	int lv_nLoop;
	Node lv_node;
	char strAddr[30];
	Address ndAddr;
	std::vector<msgTicket> lv_vecmsg;
	for( lv_nLoop = 0; lv_nLoop < repList.size(); lv_nLoop++ )
	{
		lv_node = repList.at(lv_nLoop);
		ndAddr = *lv_node.getAddress();
		stringAddress(strAddr, &ndAddr);
		
		// modify a create or update message and add replica property
		if( message.type == CREATE || message.type == UPDATE )
		{
			message.replica = static_cast<ReplicaType>(lv_nLoop);
		}
		
		// Serialized Message in string format
		string lv_str = message.toString();
		
		// Send message
		emulNet->ENsend(&memberNode->addr, &ndAddr, (char *)lv_str.c_str(), lv_str.size());

#ifdef DEBUGLOG
		sprintf(s, "dispatchMessages TransID: %d type: %d index: %d to address %s", message.transID, message.type, lv_nLoop, strAddr);
		cout<<s<< endl;
#endif
		
		// Add item to wait list
		msgTicket lv_tk(message.toString(), ndAddr, par->getcurrtime());
		lv_vecmsg.emplace_back(lv_tk);
	}
	
	transactionReplyMap.emplace(message.transID, lv_vecmsg);
}

// SBS added for MP2
void MP2Node::UpdateReplyMap(Message message)
{
	map<int, std::vector<msgTicket>>::iterator search;
	std::vector<msgTicket> lv_vecmsg;
	msgTicket lv_wt;
	int lv_nLoop;
	bool lv_bResult;
	
	search = transactionReplyMap.find(message.transID);
	if ( search != transactionReplyMap.end() ) {
		lv_vecmsg = search->second;
		for( lv_nLoop = 0; lv_nLoop < lv_vecmsg.size(); lv_nLoop++ )
		{
			lv_wt = lv_vecmsg.at(lv_nLoop);
			if( lv_wt.toAddr.getAddress() == message.fromAddr.getAddress() )
			{
				if( message.type == READREPLY ) {
					//Message lv_msg(lv_wt.m_msg);
					//lv_msg.value = message.value;
					//lv_wt.m_msg = lv_msg.toString();
					lv_wt.strValue = message.value;
					lv_bResult = (lv_wt.strValue.size() > 0);
#ifdef DEBUGLOG
					static char s[1024];
					sprintf(s, "UpdateReplyMap READREPLY TransID: %d index: %d message.value:%s", message.transID, lv_nLoop, message.value.c_str());
	//				cout<<s<< endl;
//					log->LOG(&memberNode->addr, s);
#endif					
				} else {
					lv_bResult = message.success;
				}
				lv_wt.SetReplied(lv_bResult, par->getcurrtime());
				
#ifdef DEBUGLOG
				static char s[1024];
				sprintf(s, "UpdateReplyMap TransID: %d index: %d isSucc:%d", message.transID, lv_nLoop, message.success);
//				cout<<s<< endl;
#endif				
				
				// write back
				lv_vecmsg.at(lv_nLoop) = lv_wt;
				search->second = lv_vecmsg;
				break;
			}
		}
	}
}

// SBS added for MP2
void MP2Node::CheckReplyMap()
{
#ifdef DEBUGLOG
//		cout<<"CheckReplyMap 1"<< endl;
#endif
	
	map<int, vector<msgTicket>>::iterator search, remove_wt;
	vector<msgTicket> lv_vecmsg;
	Message lv_msg(0, memberNode->addr, READ, "");
	msgTicket lv_wt("", memberNode->addr, 0);
	bool lv_blnRemove = false;
	int lv_nLoop;
	int lv_cntSucc, lv_cntTO, lv_cntFail, lv_cntNoReply;
	string lv_nSuccValue;

#ifdef DEBUGLOG
//		cout<<"CheckReplyMap 2"<< endl;
#endif
	
	if( transactionReplyMap.size() <= 0 )
		return;

#ifdef DEBUGLOG
		//cout<<"CheckReplyMap 3"<< endl;
#endif
	
	for( search = transactionReplyMap.begin(); search != transactionReplyMap.end(); search++ )
	{
		if( lv_blnRemove )
		{
			transactionReplyMap.erase(remove_wt->first);
			lv_blnRemove = false;
		}
		
		lv_vecmsg = search->second;
		lv_blnRemove = false;
		lv_cntSucc = 0;
		lv_cntTO = 0;
		lv_cntFail = 0;
		lv_cntNoReply = 0;
		for( lv_nLoop = 0; lv_nLoop < lv_vecmsg.size(); lv_nLoop++ )
		{
			lv_wt = lv_vecmsg.at(lv_nLoop);
			if( lv_wt.isRemoveTimeout(par->getcurrtime()) )
			{
				// should be removed
				lv_blnRemove = true;
				break;
			}
			Message lv_msg1(lv_wt.m_msg);
			lv_msg = lv_msg1;

#ifdef DEBUGLOG
//				static char s[1024];
//				sprintf(s, "CheckReplyMap index: %d isReplied:%d, isSucc:%d, msg: %s", lv_nLoop, lv_wt.isReplied(), lv_wt.isReplySucc(), lv_wt.m_msg.c_str());
//				cout<<s<< endl;
#endif				
			
			if( lv_wt.isReplied() ) {
				if( lv_wt.isReplySucc() )
				{
					lv_cntSucc++;
					Message lv_msg2(lv_wt.m_msg);
					lv_msg = lv_msg2;
					lv_msg.value = lv_wt.strValue;
					lv_nSuccValue = lv_wt.strValue;
				}
				else
					lv_cntFail++;
			} else {
				if( lv_wt.isTimeout(par->getcurrtime()) )
					lv_cntTO++;
				else
					lv_cntNoReply++;
			}
		}
		
		if( lv_blnRemove ) {
			remove_wt = search;
		} else {
			if( lv_cntSucc >= MAX_QUORUM ) {
				switch( lv_msg.type )
				{
					case CREATE:
						log->logCreateSuccess(&memberNode->addr, true, lv_msg.transID, lv_msg.key, lv_msg.value);
						break;
					case READ:
						log->logReadSuccess(&memberNode->addr, true, lv_msg.transID, lv_msg.key, lv_nSuccValue);
						break;
					case UPDATE:
						log->logUpdateSuccess(&memberNode->addr, true, lv_msg.transID, lv_msg.key, lv_msg.value);
						break;
					case DELETE:
						log->logDeleteSuccess(&memberNode->addr, true, lv_msg.transID, lv_msg.key);
						break;
				}
				lv_blnRemove = true;
				remove_wt = search;
			} else if( lv_cntTO + lv_cntFail >= MAX_QUORUM ) {
				switch( lv_msg.type )
				{
					case CREATE:
						log->logCreateFail(&memberNode->addr, true, lv_msg.transID, lv_msg.key, lv_msg.value);
						break;
					case READ:
						log->logReadFail(&memberNode->addr, true, lv_msg.transID, lv_msg.key);
						break;
					case UPDATE:
						log->logUpdateFail(&memberNode->addr, true, lv_msg.transID, lv_msg.key, lv_msg.value);
						break;
					case DELETE:
						log->logDeleteFail(&memberNode->addr, true, lv_msg.transID, lv_msg.key);
						break;
				}
				lv_blnRemove = true;
				remove_wt = search;
			}
		}		
	}

	if( lv_blnRemove )
	{
		transactionReplyMap.erase(remove_wt->first);
		lv_blnRemove = false;
	}	
}

/**
 * FUNCTION NAME: clientCreate
 *
 * DESCRIPTION: client side CREATE API
 * 				The function does the following:
 * 				1) Constructs the message
 * 				2) Finds the replicas of this key
 * 				3) Sends a message to the replica
 */
void MP2Node::clientCreate(string key, string value) {
	/*
	 * Implement this
	 */
	g_transID++;
		
	// Construct message
	Message lv_msg(g_transID, memberNode->addr, CREATE, key, value);
		
	// Dispatch message
	dispatchMessages(lv_msg);
}

/**
 * FUNCTION NAME: clientRead
 *
 * DESCRIPTION: client side READ API
 * 				The function does the following:
 * 				1) Constructs the message
 * 				2) Finds the replicas of this key
 * 				3) Sends a message to the replica
 */
void MP2Node::clientRead(string key){
	/*
	 * Implement this
	 */
	// SBS added for MP2
	g_transID++;

	// Construct message
	Message lv_msg(g_transID, memberNode->addr, READ, key);
		
	// Dispatch message
	dispatchMessages(lv_msg);
}

/**
 * FUNCTION NAME: clientUpdate
 *
 * DESCRIPTION: client side UPDATE API
 * 				The function does the following:
 * 				1) Constructs the message
 * 				2) Finds the replicas of this key
 * 				3) Sends a message to the replica
 */
void MP2Node::clientUpdate(string key, string value){
	/*
	 * Implement this
	 */
	// SBS added for MP2
	g_transID++;

	// Construct message
	Message lv_msg(g_transID, memberNode->addr, UPDATE, key, value);
		
	// Dispatch message
	dispatchMessages(lv_msg);
}

/**
 * FUNCTION NAME: clientDelete
 *
 * DESCRIPTION: client side DELETE API
 * 				The function does the following:
 * 				1) Constructs the message
 * 				2) Finds the replicas of this key
 * 				3) Sends a message to the replica
 */
void MP2Node::clientDelete(string key){
	/*
	 * Implement this
	 */
	// SBS added for MP2
	g_transID++;

	// Construct message
	Message lv_msg(g_transID, memberNode->addr, DELETE, key);
		
	// Dispatch message
	dispatchMessages(lv_msg);
}

/**
 * FUNCTION NAME: createKeyValue
 *
 * DESCRIPTION: Server side CREATE API
 * 			   	The function does the following:
 * 			   	1) Inserts key value into the local hash table
 * 			   	2) Return true or false based on success or failure
 */
bool MP2Node::createKeyValue(string key, string value, ReplicaType replica) {
	/*
	 * Implement this
	 */
	// Insert key, value, replicaType into the hash table
	// SBS added for MP2
	/// ToDo1: newValue = replica + value
	/// ToDo2: if existed?
	return ht->create(key, value);
}

/**
 * FUNCTION NAME: readKey
 *
 * DESCRIPTION: Server side READ API
 * 			    This function does the following:
 * 			    1) Read key from local hash table
 * 			    2) Return value
 */
string MP2Node::readKey(string key) {
	/*
	 * Implement this
	 */
	// Read key from local hash table and return value
	return ht->read(key);
}

/**
 * FUNCTION NAME: updateKeyValue
 *
 * DESCRIPTION: Server side UPDATE API
 * 				This function does the following:
 * 				1) Update the key to the new value in the local hash table
 * 				2) Return true or false based on success or failure
 */
bool MP2Node::updateKeyValue(string key, string value, ReplicaType replica) {
	/*
	 * Implement this
	 */
	// Update key in local hash table and return true or false
	return ht->update(key, value);
}

/**
 * FUNCTION NAME: deleteKey
 *
 * DESCRIPTION: Server side DELETE API
 * 				This function does the following:
 * 				1) Delete the key from the local hash table
 * 				2) Return true or false based on success or failure
 */
bool MP2Node::deletekey(string key) {
	/*
	 * Implement this
	 */
	// Delete the key from the local hash table
	return ht->deleteKey(key);
}

/**
 * FUNCTION NAME: checkMessages
 *
 * DESCRIPTION: This function is the message handler of this node.
 * 				This function does the following:
 * 				1) Pops messages from the queue
 * 				2) Handles the messages according to message types
 */
void MP2Node::checkMessages() {
	/*
	 * Implement this. Parts of it are already implemented
	 */
	char * data;
	int size;

	/*
	 * Declare your local variables here
	 */
	// SBS added for MP2
#ifdef DEBUGLOG
    static char s[1024];
#endif

	// dequeue all messages and handle them
	while ( !memberNode->mp2q.empty() ) {
		/*
		 * Pop a message from the queue
		 */
		data = (char *)memberNode->mp2q.front().elt;
		size = memberNode->mp2q.front().size;
		memberNode->mp2q.pop();

		string message(data, data + size);

		/*
		 * Handle the message types here
		 */
		// SBS added for MP2
		/// construct a message from a string
		bool result;		
		Message lv_msg(message);
		string lv_snd;
		char strAddr[30];
		Address ndAddr;
		ndAddr = lv_msg.fromAddr;
		stringAddress(strAddr, &ndAddr);
		switch(lv_msg.type)
		{
			case CREATE:
			{
#ifdef DEBUGLOG
				sprintf(s, "Received CREATE message from: %s", strAddr);
				cout<<s<< endl;
#endif			
				// Operation
				// Log
				result = createKeyValue(lv_msg.key, lv_msg.value, lv_msg.replica);
				if( result ) {
					//Address * address, bool isCoordinator, int transID, string key, string value
					log->logCreateSuccess(&memberNode->addr, false, lv_msg.transID, lv_msg.key, lv_msg.value);
				} else {
					log->logCreateFail(&memberNode->addr, false, lv_msg.transID, lv_msg.key, lv_msg.value);
				}
				
				// Reply
				Message rep_msg(lv_msg.transID, memberNode->addr, REPLY, result);
				lv_snd = rep_msg.toString();
			}
				break;
				
			case UPDATE:
			{
#ifdef DEBUGLOG
				sprintf(s, "Received UPDATE message from: %s", strAddr);
				cout<<s<< endl;
#endif			
				// Operation
				// Log
				result = updateKeyValue(lv_msg.key, lv_msg.value, lv_msg.replica);
				if( result ) {
					log->logUpdateSuccess(&memberNode->addr, false, lv_msg.transID, lv_msg.key, lv_msg.value);
				} else {
					log->logUpdateFail(&memberNode->addr, false, lv_msg.transID, lv_msg.key, lv_msg.value);
				}
				
				// Reply
				Message rep_msg(lv_msg.transID, memberNode->addr, REPLY, result);
				lv_snd = rep_msg.toString();
			}
				break;
				
			case READ:
			{
#ifdef DEBUGLOG
				sprintf(s, "Received READ message from: %s", strAddr);
				cout<<s<< endl;
#endif			
				// Operation
				// Log
				string lv_readValue = readKey(lv_msg.key);
				result = (lv_readValue.size() > 0);
				if( result ) {
					log->logReadSuccess(&memberNode->addr, false, lv_msg.transID, lv_msg.key, lv_readValue);
				} else {
					log->logReadFail(&memberNode->addr, false, lv_msg.transID, lv_msg.key);
				}
				
				// Read Reply
				Message rep_msg(lv_msg.transID, memberNode->addr, lv_readValue);
				lv_snd = rep_msg.toString();
			}
				break;
				
			case DELETE:
			{
#ifdef DEBUGLOG
				sprintf(s, "Received DELETE message from: %s", strAddr);
				cout<<s<< endl;
#endif			
				// Operation
				// Log
				result = deletekey(lv_msg.key);
				if( result ) {
					log->logDeleteSuccess(&memberNode->addr, false, lv_msg.transID, lv_msg.key);
				} else {
					log->logDeleteFail(&memberNode->addr, false, lv_msg.transID, lv_msg.key);
				}
				
				// Reply
				Message rep_msg(lv_msg.transID, memberNode->addr, REPLY, result);
				lv_snd = rep_msg.toString();
			}
				break;
				
			case REPLY:
			{
#ifdef DEBUGLOG
				sprintf(s, "Received REPLY message from: %s for TransID: %d, succ: %d", strAddr, lv_msg.transID, lv_msg.success);
				cout<<s<< endl;
#endif			
				// Update wait list
				UpdateReplyMap(lv_msg);
			}
				break;
				
			case READREPLY:
			{
#ifdef DEBUGLOG
				sprintf(s, "Received READREPLY message from: %s for TransID: %d", strAddr, lv_msg.transID);
				cout<<s<< endl;
#endif			
				// Update wait list
				UpdateReplyMap(lv_msg);
			}
				break;
		}
		
		// Send reply message
		if( lv_snd.size() > 0 ) {
			emulNet->ENsend(&memberNode->addr, &ndAddr, (char *)lv_snd.c_str(), lv_snd.size());
		}
	}

	/*
	 * This function should also ensure all READ and UPDATE operation
	 * get QUORUM replies
	 */
}

/**
 * FUNCTION NAME: findNodes
 *
 * DESCRIPTION: Find the replicas of the given keyfunction
 * 				This function is responsible for finding the replicas of a key
 */
vector<Node> MP2Node::findNodes(string key) {
	size_t pos = hashFunction(key);
	vector<Node> addr_vec;
	if (ring.size() >= 3) {
		// if pos <= min || pos > max, the leader is the min
		if (pos <= ring.at(0).getHashCode() || pos > ring.at(ring.size()-1).getHashCode()) {
			addr_vec.emplace_back(ring.at(0));
			addr_vec.emplace_back(ring.at(1));
			addr_vec.emplace_back(ring.at(2));
		}
		else {
			// go through the ring until pos <= node
			for (int i=1; i<ring.size(); i++){
				Node addr = ring.at(i);
				if (pos <= addr.getHashCode()) {
					addr_vec.emplace_back(addr);
					addr_vec.emplace_back(ring.at((i+1)%ring.size()));
					addr_vec.emplace_back(ring.at((i+2)%ring.size()));
					break;
				}
			}
		}
	}
	return addr_vec;
}

/**
 * FUNCTION NAME: recvLoop
 *
 * DESCRIPTION: Receive messages from EmulNet and push into the queue (mp2q)
 */
bool MP2Node::recvLoop() {
    if ( memberNode->bFailed ) {
    	return false;
    }
    else {
    	return emulNet->ENrecv(&(memberNode->addr), this->enqueueWrapper, NULL, 1, &(memberNode->mp2q));
    }
}

/**
 * FUNCTION NAME: enqueueWrapper
 *
 * DESCRIPTION: Enqueue the message from Emulnet into the queue of MP2Node
 */
int MP2Node::enqueueWrapper(void *env, char *buff, int size) {
	Queue q;
	return q.enqueue((queue<q_elt> *)env, (void *)buff, size);
}

/**
 * FUNCTION NAME: stabilizationProtocol
 *
 * DESCRIPTION: This runs the stabilization protocol in case of Node joins and leaves
 * 				It ensures that there always 3 copies of all keys in the DHT at all times
 * 				The function does the following:
 *				1) Ensures that there are three "CORRECT" replicas of all the keys in spite of failures and joins
 *				Note:- "CORRECT" replicas implies that every key is replicated in its two neighboring nodes in the ring
 */
void MP2Node::stabilizationProtocol() {
	/*
	 * Implement this
	 */
	map<string, string>::iterator search;
	vector<Node> repList;
	string lv_key;
	string lv_value;
	string lv_removekey;
	int lv_nLoop;
	for( search = ht->hashTable.begin(); search != ht->hashTable.end(); search++ )
	{
		if( !lv_removekey.empty() )
		{
			ht->deleteKey(lv_removekey);
			lv_removekey.clear();
		}
		
		lv_key = search->first;
		lv_value = search->second;
		//lv_removekey.clear();
		
		repList = findNodes(lv_key);
		
		// Remove the key if I'm not a replica any more
		lv_removekey = lv_key;
		for( lv_nLoop = 0; lv_nLoop < repList.size(); lv_nLoop++ )
		{
			if( repList.at(lv_nLoop).getAddress()->getAddress() == memberNode->addr.getAddress() )
			{
				// Still a replica
				lv_removekey.clear();
				break;
			}
		}
		
		// Create new replicas
		clientCreate(lv_key, lv_value);
	}
	
	if( !lv_removekey.empty() )
	{
		ht->deleteKey(lv_removekey);
		lv_removekey.clear();
	}
}

char *MP2Node::stringAddress(char *strAddr, Address *addr)
{
	if (strAddr == NULL) {
		return NULL;
	}
	
	sprintf(strAddr, "%d.%d.%d.%d:%d",  addr->addr[0],addr->addr[1],addr->addr[2],
                                                      addr->addr[3], *(short*)&addr->addr[4]);
	return strAddr;
}