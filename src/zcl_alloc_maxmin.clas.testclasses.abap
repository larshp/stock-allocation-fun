CLASS ltcl_alloc_maxmin DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_maxmin.

    METHODS setup.

    METHODS even_split     FOR TESTING.
    METHODS small_demand   FOR TESTING.
    METHODS three_equal    FOR TESTING.
    METHODS all_satisfied  FOR TESTING.
    METHODS empty_list     FOR TESTING.
    METHODS zero_available FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_maxmin IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_maxmin( ).
  ENDMETHOD.

  METHOD even_split.
    DATA lt_demands TYPE zcl_alloc_maxmin=>ty_qty_tt.

    APPEND '10' TO lt_demands.
    APPEND '10' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands   = lt_demands
                                        iv_available = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '2' ).
  ENDMETHOD.

  METHOD small_demand.
    DATA lt_demands TYPE zcl_alloc_maxmin=>ty_qty_tt.

    APPEND '2' TO lt_demands.
    APPEND '10' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands   = lt_demands
                                        iv_available = '6' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '4' ).
  ENDMETHOD.

  METHOD three_equal.
    DATA lt_demands TYPE zcl_alloc_maxmin=>ty_qty_tt.

    APPEND '5' TO lt_demands.
    APPEND '5' TO lt_demands.
    APPEND '5' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands   = lt_demands
                                        iv_available = '6' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 3 ]-granted exp = '2' ).
  ENDMETHOD.

  METHOD all_satisfied.
    DATA lt_demands TYPE zcl_alloc_maxmin=>ty_qty_tt.

    APPEND '1' TO lt_demands.
    APPEND '1' TO lt_demands.
    APPEND '1' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands   = lt_demands
                                        iv_available = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 3 ]-granted exp = '1' ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_demands TYPE zcl_alloc_maxmin=>ty_qty_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->allocate( it_demands   = lt_demands
                              iv_available = '10' ) ).
  ENDMETHOD.

  METHOD zero_available.
    DATA lt_demands TYPE zcl_alloc_maxmin=>ty_qty_tt.

    APPEND '10' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands   = lt_demands
                                        iv_available = '0' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '0' ).
  ENDMETHOD.

ENDCLASS.
