package test_main

import (
	"testing"
)

func TestMarketDirectOfferSoft(t *testing.T) {

	price := 10.0
	t.Run("Should be able to add direct offer and then sell", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			acceptDirectOfferMarketSoft("user1", id, "user2", price).
			saleItemListed("user1", "directoffer_soft_accepted", price).
			fulfillMarketDirectOfferSoft("user2", id, price)
	})

	t.Run("Should be able to increase offer", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			increaseDirectOfferMarketSoft("user2", id, 5.0, 15.0).
			saleItemListed("user1", "directoffer_soft", 15.0)
	})

	t.Run("Should be able to reject offer", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			rejectDirectOfferSoft("user1", id, 10.0)
	})

	t.Run("Should be able to retract offer", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			retractOfferDirectOfferSoft("user2", "user1", id)
	})


	t.Run("Should not be able to add direct offer when deprecated", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			alterMarketOption("DirectOfferSoft", "deprecate")

		otu.O.TransactionFromFile("bidMarketDirectOfferSoft").
			SignProposeAndPayAs("user2").
			Args(otu.O.Arguments().
				Account("user1").
				String("Dandy").
				UInt64(id).
				String("Flow").
				UFix64(price)).
			Test(otu.T).
			AssertFailure("Tenant has deprected mutation options on this item")
	})

	t.Run("Should not be able to increase bid but able to fulfill offer when deprecated", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			alterMarketOption("DirectOfferSoft", "deprecate")

		otu.O.TransactionFromFile("increaseBidMarketDirectOfferSoft").
			SignProposeAndPayAs("user2").
			Args(otu.O.Arguments().
				UInt64(id).
				UFix64(price)).
			Test(otu.T).
			AssertFailure("Tenant has deprected mutation options on this item")

		otu.acceptDirectOfferMarketSoft("user1", id, "user2", price).
			saleItemListed("user1", "directoffer_soft_accepted", price).
			fulfillMarketDirectOfferSoft("user2", id, price)
	})

	t.Run("Should be able to reject offer when deprecated", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			alterMarketOption("DirectOfferSoft", "deprecate").
			rejectDirectOfferSoft("user1", id, 10.0)
	})

	t.Run("Should not be able to add direct offer after stopped", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			alterMarketOption("DirectOfferSoft", "stop")

		otu.O.TransactionFromFile("bidMarketDirectOfferSoft").
			SignProposeAndPayAs("user2").
			Args(otu.O.Arguments().
				Account("user1").
				String("Dandy").
				UInt64(id).
				String("Flow").
				UFix64(price)).
			Test(otu.T).
			AssertFailure("Tenant has stopped this item")
	})

	t.Run("Should not be able to increase bid nor accept offer after stopped", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			alterMarketOption("DirectOfferSoft", "stop")

		otu.O.TransactionFromFile("increaseBidMarketDirectOfferSoft").
			SignProposeAndPayAs("user2").
			Args(otu.O.Arguments().
				UInt64(id).
				UFix64(price)).
			Test(otu.T).
			AssertFailure("Tenant has stopped this item")

		otu.O.TransactionFromFile("acceptDirectOfferSoft").
			SignProposeAndPayAs("user1").
			Args(otu.O.Arguments().
				UInt64(id)).
			Test(otu.T).
			AssertFailure("Tenant has stopped this item")
	})

	t.Run("Should not be able to fulfill offer after stopped", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			acceptDirectOfferMarketSoft("user1", id, "user2", price).
			saleItemListed("user1", "directoffer_soft_accepted", price).
			alterMarketOption("DirectOfferSoft", "stop")

		otu.O.TransactionFromFile("fulfillMarketDirectOfferSoft").
			SignProposeAndPayAs("user2").
			Args(otu.O.Arguments().
				UInt64(id)).
			Test(otu.T).
			AssertFailure("Tenant has stopped this item")
	})

	t.Run("Should not be able to reject offer after stopped", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			alterMarketOption("DirectOfferSoft", "stop")

		otu.O.TransactionFromFile("cancelMarketDirectOfferSoft").
			SignProposeAndPayAs("user1").
			Args(otu.O.Arguments().
				UInt64Array(id)).
			Test(otu.T).
			AssertFailure("Tenant has stopped this item")
	})

	t.Run("Should be able to direct offer, increase offer and fulfill offer after enabled", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			alterMarketOption("DirectOfferSoft", "stop").
			alterMarketOption("DirectOfferSoft", "enable").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			acceptDirectOfferMarketSoft("user1", id, "user2", price).
			saleItemListed("user1", "directoffer_soft_accepted", price).
			fulfillMarketDirectOfferSoft("user2", id, price)
	})

	t.Run("Should be able to reject offer after enabled", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			alterMarketOption("DirectOfferSoft", "stop").
			alterMarketOption("DirectOfferSoft", "enable").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			rejectDirectOfferSoft("user1", id, 10.0)
	})

	t.Run("Should not be able to make offer by user3 when deprecated or stopped", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price).
			alterMarketOption("DirectOfferSoft", "deprecate")

		otu.O.TransactionFromFile("bidMarketDirectOfferSoft").
			SignProposeAndPayAs("user3").
			Args(otu.O.Arguments().
				Account("user1").
				String("Dandy").
				UInt64(id).
				String("Flow").
				UFix64(price + 10.0)).
			Test(otu.T).
			AssertFailure("Tenant has deprected mutation options on this item")

		otu.alterMarketOption("DirectOfferSoft", "stop")

		otu.O.TransactionFromFile("bidMarketDirectOfferSoft").
			SignProposeAndPayAs("user3").
			Args(otu.O.Arguments().
				Account("user1").
				String("Dandy").
				UInt64(id).
				String("Flow").
				UFix64(price + 10.0)).
			Test(otu.T).
			AssertFailure("Tenant has stopped this item")
	})

	t.Run("Should be able to retract offer when deprecated , but not when stopped", func(t *testing.T) {
		otu := NewOverflowTest(t)

		id := otu.setupMarketAndDandy()
		otu.registerFlowFUSDDandyInRegistry().
			setFlowDandyMarketOption("DirectOfferSoft").
			directOfferMarketSoft("user2", "user1", id, price).
			saleItemListed("user1", "directoffer_soft", price)

		otu.alterMarketOption("DirectOfferSoft", "stop")

		otu.O.TransactionFromFile("retractOfferMarketDirectOfferSoft").
			SignProposeAndPayAs("user2").
			Args(otu.O.Arguments().
				UInt64(id)).
			Test(otu.T).AssertFailure("Tenant has stopped this item")

		otu.alterMarketOption("DirectOfferSoft", "deprecate").
			retractOfferDirectOfferSoft("user2", "user1", id)
	})

}