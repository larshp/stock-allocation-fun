CLASS ltcl_whole_units DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_unit_size     TYPE zif_allocation=>ty_quantity DEFAULT 12
        iv_priority      TYPE zif_allocation=>ty_priority DEFAULT '01'
        iv_complete      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS allocate
      IMPORTING
        it_demand            TYPE zif_allocation=>ty_demand_tab
        iv_available         TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

    METHODS a_part_carton_is_cut_off FOR TESTING.
    METHODS a_whole_line_is_untouched FOR TESTING.
    METHODS the_shortfall_is_the_rest FOR TESTING.
    METHODS what_is_cut_off_is_offered FOR TESTING.
    METHODS pieces_are_left_alone FOR TESTING.
    METHODS less_than_one_unit_is_nothing FOR TESTING.
    METHODS every_line_is_answered_once FOR TESTING.
    METHODS complete_delivery_still_works FOR TESTING.

ENDCLASS.


CLASS ltcl_whole_units IMPLEMENTATION.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = 'MAT-1'
      werks     = '1000'
      quantity  = iv_quantity
      req_date  = '20260101'
      priority  = iv_priority
      complete  = iv_complete
      unit_size = iv_unit_size ).

  ENDMETHOD.

  METHOD allocate.

    DATA(lo_cut) = CAST zif_allocation_strategy( NEW zcl_alloc_whole_units(
      NEW zcl_alloc_strategy_priority( ) ) ).

    rt_allocation = lo_cut->allocate(
      iv_available = iv_available
      it_demand    = it_demand ).

  ENDMETHOD.

  METHOD a_part_carton_is_cut_off.

    " 20 pieces of a material sold in cartons of twelve is one carton
    DATA(lt_allocation) = allocate(
      iv_available = '20'
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = '60' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-confirmed
      exp = '12'
      msg = 'a customer ordering cartons cannot be sent two thirds of one' ).

  ENDMETHOD.

  METHOD a_whole_line_is_untouched.

    DATA(lt_allocation) = allocate(
      iv_available = '100'
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = '60' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-confirmed
      exp = '60'
      msg = 'a line served in full is already a whole number of units' ).

  ENDMETHOD.

  METHOD the_shortfall_is_the_rest.

    DATA(lt_allocation) = allocate(
      iv_available = '20'
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = '60' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-requested
      exp = '60'
      msg = 'the answer is about what was asked for, not what the rule allowed' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-shortfall
      exp = '48'
      msg = 'and what was cut off is short, not quietly gone' ).

  ENDMETHOD.

  METHOD what_is_cut_off_is_offered.

    " the carton line takes 12 of the 20 and cannot use the other 8, so the
    " line that sells in pieces gets them rather than nobody
    DATA(lt_allocation) = allocate(
      iv_available = '20'
      it_demand    = VALUE #(
        ( demand( iv_id = 'D1' iv_quantity = '60' iv_priority = '01' ) )
        ( demand( iv_id = 'D2' iv_quantity = '30' iv_priority = '02'
                  iv_unit_size = 1 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-confirmed
      exp = '12' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D2' ]-confirmed
      exp = '8'
      msg = 'what one line cannot use must reach a line that can' ).

  ENDMETHOD.

  METHOD pieces_are_left_alone.

    DATA(lt_allocation) = allocate(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand( iv_id = 'D1' iv_quantity = '10' iv_unit_size = 1 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-confirmed
      exp = '7'
      msg = 'a line ordered in the base unit is whole whatever it gets' ).

  ENDMETHOD.

  METHOD less_than_one_unit_is_nothing.

    DATA(lt_allocation) = allocate(
      iv_available = '11'
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = '60' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-confirmed
      exp = 0
      msg = 'eleven of a twelve is not a carton, so it is not a confirmation' ).

  ENDMETHOD.

  METHOD every_line_is_answered_once.

    DATA(lt_allocation) = allocate(
      iv_available = '20'
      it_demand    = VALUE #(
        ( demand( iv_id = 'D1' iv_quantity = '60' iv_priority = '01' ) )
        ( demand( iv_id = 'D2' iv_quantity = '24' iv_priority = '02' ) )
        ( demand( iv_id = 'D3' iv_quantity = '12' iv_priority = '03' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_allocation )
      exp = 3
      msg = 'every demand line is answered exactly once, cut or not' ).

  ENDMETHOD.

  METHOD complete_delivery_still_works.

    " the complete delivery rule sits outside this one, so it sees the cut
    " quantity and drops a line that cannot be served in full
    DATA(lo_cut) = CAST zif_allocation_strategy( NEW zcl_alloc_all_or_nothing(
      NEW zcl_alloc_whole_units( NEW zcl_alloc_strategy_priority( ) ) ) ).

    DATA(lt_allocation) = lo_cut->allocate(
      iv_available = '20'
      it_demand    = VALUE #(
        ( demand( iv_id = 'D1' iv_quantity = '24' iv_priority = '01'
                  iv_complete = abap_true ) )
        ( demand( iv_id = 'D2' iv_quantity = '12' iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D1' ]-confirmed
      exp = 0
      msg = 'two cartons or nothing, and only one of them is there' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocation[ demand_id = 'D2' ]-confirmed
      exp = '12'
      msg = 'and the carton it gave up goes to the line that can take one' ).

  ENDMETHOD.

ENDCLASS.
