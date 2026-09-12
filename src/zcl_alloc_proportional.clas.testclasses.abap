CLASS ltcl_alloc_proportional DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_proportional.

    METHODS setup.

    METHODS even_split      FOR TESTING.
    METHODS unequal_split   FOR TESTING.
    METHODS rounding_left   FOR TESTING.
    METHODS above_total     FOR TESTING.
    METHODS empty_list      FOR TESTING.
    METHODS zero_demands    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_proportional IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_proportional( ).
  ENDMETHOD.

  METHOD even_split.
    DATA lt_demands TYPE zcl_alloc_proportional=>ty_qty_tt.

    APPEND '10' TO lt_demands.
    APPEND '10' TO lt_demands.

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '2' ).
  ENDMETHOD.

  METHOD unequal_split.
    DATA lt_demands TYPE zcl_alloc_proportional=>ty_qty_tt.

    APPEND '30' TO lt_demands.
    APPEND '10' TO lt_demands.

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '1' ).
  ENDMETHOD.

  METHOD rounding_left.
    DATA lt_demands TYPE zcl_alloc_proportional=>ty_qty_tt.

    APPEND '10' TO lt_demands.
    APPEND '10' TO lt_demands.
    APPEND '10' TO lt_demands.

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 3 ]-granted exp = '3' ).
  ENDMETHOD.

  METHOD above_total.
    DATA lt_demands TYPE zcl_alloc_proportional=>ty_qty_tt.

    APPEND '3' TO lt_demands.
    APPEND '4' TO lt_demands.

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '100' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '4' ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_demands TYPE zcl_alloc_proportional=>ty_qty_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->distribute( it_demands   = lt_demands
                                iv_available = '10' ) ).
  ENDMETHOD.

  METHOD zero_demands.
    DATA lt_demands TYPE zcl_alloc_proportional=>ty_qty_tt.

    APPEND '0' TO lt_demands.
    APPEND '0' TO lt_demands.

    DATA(lt_grants) = mo_cut->distribute( it_demands   = lt_demands
                                          iv_available = '5' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '0' ).
  ENDMETHOD.

ENDCLASS.
