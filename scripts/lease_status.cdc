import FIN from "../contracts/FIN.cdc"

//Check the status of a fin user
pub fun main(tag: String, user: Address) : FIN.LeaseInformation {

	  let leaseCollection = getAccount(user).getCapability<&{FIN.LeaseCollectionPublic}>(FIN.LeasePublicPath)
		return leaseCollection.borrow()!.getLease(tag)!
}