func scaledParams(region_count_:Nat, factor:Nat) : T.WorkloadParams = {
  {
    region_count        = region_count_:Nat;
    day_count           = 3:Nat;
    max_route_duration  = 1:Nat;
    producer_count      = region_count * factor;
    transporter_count   = region_count * factor;
    retailer_count      = region_count * factor;
  }
};
let _ = server.loadWorkload(scaledParams(region_count, scale_factor));
server.getCounts()
