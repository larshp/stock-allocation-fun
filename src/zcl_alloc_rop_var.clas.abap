CLASS zcl_alloc_rop_var DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             avg_demand TYPE menge_d,
             lead_time  TYPE i,
             sigma      TYPE menge_d,
             z_x100     TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             cycle_stock TYPE menge_d,
             safety      TYPE menge_d,
             rop         TYPE menge_d,
           END OF ty_result.

    METHODS calculate
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_rop_var IMPLEMENTATION.

  METHOD calculate.
    DATA lo_safety TYPE REF TO zcl_alloc_safety_level.
    DATA ls_safety TYPE zcl_alloc_safety_level=>ty_input.

    lo_safety = NEW zcl_alloc_safety_level( ).

    ls_safety-avg_demand = is_input-avg_demand.
    ls_safety-sigma = is_input-sigma.
    ls_safety-lead_time = is_input-lead_time.
    ls_safety-z_x100 = is_input-z_x100.

    IF is_input-avg_demand > 0 AND is_input-lead_time > 0.
      rs_result-cycle_stock = is_input-avg_demand * is_input-lead_time.
    ENDIF.

    rs_result-safety = lo_safety->calculate( ls_safety ).
    rs_result-rop = rs_result-cycle_stock + rs_result-safety.
  ENDMETHOD.

ENDCLASS.
