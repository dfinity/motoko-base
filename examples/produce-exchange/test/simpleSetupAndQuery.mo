import Debug "mo:base/Debug";
import T = "../src/serverTypes";
import A = "../src/serverActor";
import Result = "mo:base/Result";
import Option = "mo:base/Option";

func printEntityCount(entname:Text, count:Nat) {
  Debug.print ("- " # entname # " count: " # debug_show count # "\n");
};

func printLabeledCost(lab:Text, cost:Nat) {
  Debug.print ("- " # lab # " cost: " # debug_show cost # "\n");
};

actor class Test() = this {
  public func go() {
    ignore(async
    {
      let s = A.Server();

      Debug.print "\nExchange setup: Begin...\n====================================\n";

      let pka = "beef";
      let pkb = "dead";
      let pkc = "4242";
      let pkd = "1234";
      let pke = "f00d";

      // populate with truck types
      let tta = await s.registrarAddTruckType("tta", "", 10, false, false);
      let ttb = await s.registrarAddTruckType("ttb", "", 20, false, false);
      let ttc = await s.registrarAddTruckType("ttc", "", 10, true, false);
      let ttd = await s.registrarAddTruckType("ttd", "", 30, true, false);
      let tte = await s.registrarAddTruckType("tte", "", 50, false, true);

      printEntityCount("Truck type", (await s.getCounts()).truck_type_count);

      // populate with regions
      let rega = await s.registrarAddRegion("rega", "");
      let regb = await s.registrarAddRegion("regb", "");
      let regc = await s.registrarAddRegion("regc", "");
      let regd = await s.registrarAddRegion("regd", "");
      let rege = await s.registrarAddRegion("rege", "");

      printEntityCount("Region", (await s.getCounts()).region_count);

      // populate with produce
      let pea = await s.registrarAddProduce("avocado1", "avocado", 1);
      let peb = await s.registrarAddProduce("avocado2", "avocado avocado", 2);
      let pec = await s.registrarAddProduce("avocado3", "avocado avocado avocado", 3);
      let ped = await s.registrarAddProduce("avocado4", "avocado avocado avocado avocado", 4);
      let pee = await s.registrarAddProduce("avocado5", "avocado avocado avocado avocado avocado", 5);

      printEntityCount("Produce", (await s.getCounts()).produce_count);

      // register all users
      let uida = await s.registrarAddUser(pka, "usera", "", Result.unwrapOk rega, true, true, true, true);
      let uidb = await s.registrarAddUser(pkb, "userb", "", Result.unwrapOk regb, true, true, true, true);
      let uidc = await s.registrarAddUser(pkc, "userc", "", Result.unwrapOk regc, true, true, true, true);
      let uidd = await s.registrarAddUser(pkd, "userd", "", Result.unwrapOk regd, true, true, true, true);
      let uide = await s.registrarAddUser(pke, "usere", "", Result.unwrapOk rege, true, true, true, true);

      printEntityCount("Producer", (await s.getCounts()).producer_count);
      printEntityCount("Transporter", (await s.getCounts()).transporter_count);
      printEntityCount("Retailer", (await s.getCounts()).retailer_count);

      // populate with inventory
      let praia = await s.producerAddInventory(
        pka,
        Result.unwrapOk uida,
        Result.unwrapOk pea, 100, 100, 10, 0, 110, ""
      );
      let praib = await s.producerAddInventory(
        pka,
        Result.unwrapOk uida,
        Result.unwrapOk peb, 200, 200, 10, 1, 111, ""
      );
      let praic = await s.producerAddInventory(
        pka,
        Result.unwrapOk uida,
        Result.unwrapOk pec, 300, 300, 10, 2, 112, ""
      );
      let prbia = await s.producerAddInventory(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk peb, 200, 200, 10, 4, 117, ""
      );
      let prbib = await s.producerAddInventory(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk peb, 1500, 1600, 9, 2, 115, ""
      );
      let prbic = await s.producerAddInventory(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk pec, 300, 300, 10, 2, 112, ""
      );
      let prcia = await s.producerAddInventory(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk peb, 200, 200, 9, 4, 711, ""
      );
      let prdib = await s.producerAddInventory(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk peb, 1500, 1500, 7, 2, 115, ""
      );
      let prdic = await s.producerAddInventory(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk pec, 300, 300, 6, 2, 112, ""
      );

      printEntityCount("Inventory@time1", (await s.getCounts()).inventory_count);

      ////////////////////////////////////////////////////////////////////////////////////

      /**- remove some of the inventory items added above */

      //assertOk(await s.producerRemInventory(pkd, assertUnwrapAny<InventoryId>(prdib)));

      // a double-remove should return null
      //assertErr(await s.producerRemInventory(pkb, assertUnwrapAny<InventoryId>(prdib)));

      //assertOk(await s.producerRemInventory(pka, assertUnwrapAny<InventoryId>(praib)));

      // a double-remove should return null
      //assertErr(await s.producerRemInventory(pka, assertUnwrapAny<InventoryId>(praib)));

      printEntityCount("Inventory@time2", (await s.getCounts()).inventory_count);

      ////////////////////////////////////////////////////////////////////////////////////

      /**- update some of the (remaining) inventory items added above */

      Result.assertOk(
        await s.producerUpdateInventory(
          pka,
          Result.unwrapOk praic,
          Result.unwrapOk uida,
          Result.unwrapOk pec, 666, 300, 10, 2, 112, ""
        ));

      Result.assertOk(
        await s.producerUpdateInventory(
          pkb,
          Result.unwrapOk prbia,
          Result.unwrapOk uidb,
          Result.unwrapOk peb, 200, 666, 10, 4, 117, ""
        ));

      Result.assertOk(
        await s.producerUpdateInventory(
          pkb,
          Result.unwrapOk prbib,
          Result.unwrapOk uidb,
          Result.unwrapOk peb, 666, 1600, 9, 2, 115, ""
        ));

      printEntityCount("Inventory@time3", (await s.getCounts()).inventory_count);

      ////////////////////////////////////////////////////////////////////////////////////

      /**- populate with routes */

      let rta_a_c_tta = await s.transporterAddRoute(
        pka,
        Result.unwrapOk uida,
        Result.unwrapOk rega,
        Result.unwrapOk regc,
        0, 20, 100,
        Result.unwrapOk tta
      );
      let rta_b_c_ttb = await s.transporterAddRoute(
        pka,
        Result.unwrapOk uida,
        Result.unwrapOk regb,
        Result.unwrapOk regc,
        0, 20, 100,
        Result.unwrapOk ttb
      );
      let rta_a_c_ttc = await s.transporterAddRoute(
        pka,
        Result.unwrapOk uida,
        Result.unwrapOk rega,
        Result.unwrapOk rege,
        0, 20, 100,
        Result.unwrapOk ttc
      );

      let rtb_a_c_tta = await s.transporterAddRoute(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk regc,
        Result.unwrapOk rege,
        0, 20, 40,
        Result.unwrapOk tta
      );
      let rtb_b_c_ttb = await s.transporterAddRoute(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk regb,
        Result.unwrapOk regc,
        0, 40, 70,
        Result.unwrapOk ttb
      );
      let rtb_a_c_ttc = await s.transporterAddRoute(
        pkb,
        Result.unwrapOk uidb,
        Result.unwrapOk rega,
        Result.unwrapOk regc,
        20, 40, 97,
        Result.unwrapOk ttc
      );

      let rtc_b_c_tta = await s.transporterAddRoute(
        pkc,
        Result.unwrapOk uidc,
        Result.unwrapOk regb,
        Result.unwrapOk regb,
        20, 40, 40,
        Result.unwrapOk tta
      );
      let rtc_c_e_tta = await s.transporterAddRoute(
        pkc,
        Result.unwrapOk uidc,
        Result.unwrapOk regc,
        Result.unwrapOk regb,
        20, 40, 70,
        Result.unwrapOk tta
      );
      let rtc_a_c_ttc = await s.transporterAddRoute(
        pkc,
        Result.unwrapOk uidc,
        Result.unwrapOk rega,
        Result.unwrapOk regc,
        20, 40, 97,
        Result.unwrapOk ttc
      );

      let rtd_b_c_ttb = await s.transporterAddRoute(
        pkd,
        Result.unwrapOk uidd,
        Result.unwrapOk regb,
        Result.unwrapOk regd,
        20, 40, 50,
        Result.unwrapOk ttb
      );
      let rtd_c_e_tta = await s.transporterAddRoute(
        pkd,
        Result.unwrapOk uidd,
        Result.unwrapOk regc,
        Result.unwrapOk regd,
        20, 40, 70,
        Result.unwrapOk tta
      );

      let rte_a_c_ttc = await s.transporterAddRoute(
        pke,
        Result.unwrapOk uide,
        Result.unwrapOk rega,
        Result.unwrapOk regd,
        20, 40, 97,
        Result.unwrapOk ttc
      );

      printEntityCount("Route@time1", (await s.getCounts()).route_count);

      ////////////////////////////////////////////////////////////////////////////////////

      /**- remove some of the routes added above */

      //assertOk(await s.transporterRemRoute(pkc, assertUnwrapAny<RouteId>(rtc_b_c_tta)));

      // a double-remove should return null
      //assertErr(await s.transporterRemRoute(pkc, assertUnwrapAny<RouteId>(rtc_b_c_tta)));

      printEntityCount("Route@time2", (await s.getCounts()).route_count);

      //assertOk(await s.transporterRemRoute(pkc, assertUnwrapAny<RouteId>(rtc_c_e_tta)));

      // a double-remove should return null
      //assertErr(await s.transporterRemRoute(pkc, assertUnwrapAny<RouteId>(rtc_c_e_tta)));

      printEntityCount("Route@time3", (await s.getCounts()).route_count);

      //////////////////////////////////////////////////////////////////

      Debug.print "\nExchange setup: Done.\n====================================\n";

      await debugDumpAll(s);

      //////////////////////////////////////////////////////////////////

      Debug.print "\nRetailer queries\n====================================\n";

      // do some queries
      await retailerQueryAll(s, pka, ? Result.unwrapOk uida);
      await retailerQueryAll(s, pkb, ? Result.unwrapOk uidb);
      await retailerQueryAll(s, pkc, ? Result.unwrapOk uidc);
      await retailerQueryAll(s, pkd, ? Result.unwrapOk uidd);
      await retailerQueryAll(s, pke, ? Result.unwrapOk uide);

      Debug.print "\nQuery counts\n----------------\n";
      let counts = await s.getCounts();

      printEntityCount("Retailer join", counts.retailer_join_count);
      printEntityCount("Retailer query", counts.retailer_query_count);
      printLabeledCost("Retailer query", counts.retailer_query_cost);

      Debug.print "\nAuthentication test:\n====================================\n";

      Debug.print "\npk a == uid a";
      assert(await s.validateUser(pka, Result.unwrapOk uida));
      Debug.print "\npk b == uid b";
      assert(await s.validateUser(pkb, Result.unwrapOk uidb));
      Debug.print "\npk a != uid b";
      assert(not(await s.validateUser(pka, Result.unwrapOk uidb)));
      Debug.print "\npk b != uid a";
      assert(not(await s.validateUser(pkb, Result.unwrapOk uida)));

      //////////////////////////////////////////////////////////////////
      // xxx --- todo: separate test(s) for expected failures
      // User c should not be able to remove user a's route
      if false {
        Debug.print "\nAuthentication test, expect Result.assertion failure:\n";
        ignore(await s.transporterRemRoute(pkc, Result.unwrapOk rta_a_c_tta))
      };
      Debug.print "\n";
    })
  };
};


func retailerQueryAll(server:A.Server, pk:Text, r:?T.UserId) : async () {

  let retailerId: T.UserId = Option.unwrap<T.UserId>(r);
  Debug.print ("\nRetailer " # debug_show retailerId # " sends `retailerQueryAll`\n");
  Debug.print "------------------------------------\n";

  Debug.print "\n## Query begin:\n";
  let res = Result.unwrapOk(
    await server.retailerQueryAll(pk, retailerId, null, null)
  );
  Debug.print "\n## Query end.";

  Debug.print ("\n## Query results (" # debug_show res.size() # ")\n");
  for (info in res.vals()) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  }
};

func debugDumpAll(server:A.Server) : async () {

  Debug.print "\nTruck type info\n----------------\n";
  for ( info in ((await server.allTruckTypeInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };

  Debug.print "\nRegion info\n----------------\n";
  for ( info in ((await server.allRegionInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };

  Debug.print "\nProduce info\n----------------\n";
  for ( info in ((await server.allProduceInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };

  Debug.print "\nProducer info\n----------------\n";
  for ( info in ((await server.allProducerInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };

  Debug.print "\nTransporter info\n----------------\n";
  for ( info in ((await server.allTransporterInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };

  Debug.print "\nRetailer info\n----------------\n";
  for ( info in ((await server.allRetailerInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };

  Debug.print "\nInventory info\n----------------\n";
  for ( info in ((await server.allInventoryInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };

  Debug.print "\nRoute info\n----------------\n";
  for ( info in ((await server.allRouteInfo()).vals()) ) {
    Debug.print "- ";
    Debug.print (debug_show info);
    Debug.print "\n";
  };
};

let test = Test();
test.go()
