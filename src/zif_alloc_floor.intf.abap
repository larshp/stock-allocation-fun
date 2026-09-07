INTERFACE zif_alloc_floor PUBLIC.

  "! What one demand line is to get before the distribution rules see the
  "! stock at all.
  TYPES:
    BEGIN OF ty_floor,
      demand_id TYPE zif_allocation=>ty_demand_id,
      quantity  TYPE zif_allocation=>ty_quantity,
    END OF ty_floor.
  TYPES ty_floor_tab TYPE STANDARD TABLE OF ty_floor WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Quantities that are handed over before the rules run</p>
  "!
  "! Asked once per call of the strategy, with the demand of one material in
  "! one plant: everything a source needs to know is in there, and a source
  "! that has nothing to say for this material answers with nothing.
  "!
  "! @parameter it_demand | <p class="shorttext synchronized">Demand of one material in one plant</p>
  "! @parameter rt_floor  | <p class="shorttext synchronized">What each line gets first, if anything</p>
  METHODS floors_for
    IMPORTING
      it_demand       TYPE zif_allocation=>ty_demand_tab
    RETURNING
      VALUE(rt_floor) TYPE ty_floor_tab.

ENDINTERFACE.
