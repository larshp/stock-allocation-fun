CLASS ltcl_alloc_round_robin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_round_robin.

    METHODS setup.

    METHODS add
      IMPORTING
        it_demands        TYPE zcl_alloc_round_robin=>ty_qty_tt
        iv_quantity       TYPE menge_d
      RETURNING
        VALUE(rt_demands) TYPE zcl_alloc_round_robin=>ty_qty_tt.

    METHODS empty_list      FOR TESTING.
    METHODS even_split      FOR TESTING.
    METHODS odd_remainder   FOR TESTING.
    METHODS all_satisfied   FOR TESTING.
    METHODS zero_available  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_round_robin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_round_robin( ).
  ENDMETHOD.

  METHOD add.
    rt_demands = it_demands.
    APPEND iv_quantity TO rt_demands.
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_demands TYPE zcl_alloc_round_robin=>ty_qty_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->distribute( it_demands   = lt_demands
                                iv_available = '10' ) ).
  ENDMETHOD.

  METHOD even_split.
    DATA lt_demands TYPE zcl_alloc_round_robin=>ty_qty_tt.

    lt_demands = add( it_demands  = lt_demands
                      iv_quantity = '10' ).
    lt_demands = add( it_demands  = lt_demands
                      iv_quantity = '10' ).

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '2' ).
  ENDMETHOD.

  METHOD odd_remainder.
    DATA lt_demands TYPE zcl_alloc_round_robin=>ty_qty_tt.

    lt_demands = add( it_demands  = lt_demands
                      iv_quantity = '10' ).
    lt_demands = add( it_demands  = lt_demands
                      iv_quantity = '10' ).

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '3' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '1' ).
  ENDMETHOD.

  METHOD all_satisfied.
    DATA lt_demands TYPE zcl_alloc_round_robin=>ty_qty_tt.

    lt_demands = add( it_demands  = lt_demands
                      iv_quantity = '3' ).
    lt_demands = add( it_demands  = lt_demands
                      iv_quantity = '4' ).

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '4' ).
  ENDMETHOD.

  METHOD zero_available.
    DATA lt_demands TYPE zcl_alloc_round_robin=>ty_qty_tt.

    lt_demands = add( it_demands  = lt_demands
                      iv_quantity = '10' ).

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '0' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '0' ).
  ENDMETHOD.

ENDCLASS.
