CLASS ltcl_alloc_capacity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_capacity.

    METHODS setup.

    METHODS capacity_limits  FOR TESTING.
    METHODS capacity_above   FOR TESTING.
    METHODS second_partial   FOR TESTING.
    METHODS zero_capacity    FOR TESTING.
    METHODS negative_demand  FOR TESTING.
    METHODS empty_list       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_capacity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_capacity( ).
  ENDMETHOD.

  METHOD capacity_limits.
    DATA lt_demands TYPE zcl_alloc_capacity=>ty_qty_tt.

    APPEND '10' TO lt_demands.
    APPEND '10' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands  = lt_demands
                                        iv_capacity = '12' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '2' ).
  ENDMETHOD.

  METHOD capacity_above.
    DATA lt_demands TYPE zcl_alloc_capacity=>ty_qty_tt.

    APPEND '5' TO lt_demands.
    APPEND '5' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands  = lt_demands
                                        iv_capacity = '100' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '5' ).
  ENDMETHOD.

  METHOD second_partial.
    DATA lt_demands TYPE zcl_alloc_capacity=>ty_qty_tt.

    APPEND '3' TO lt_demands.
    APPEND '5' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands  = lt_demands
                                        iv_capacity = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '1' ).
  ENDMETHOD.

  METHOD zero_capacity.
    DATA lt_demands TYPE zcl_alloc_capacity=>ty_qty_tt.

    APPEND '5' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands  = lt_demands
                                        iv_capacity = '0' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '0' ).
  ENDMETHOD.

  METHOD negative_demand.
    DATA lt_demands TYPE zcl_alloc_capacity=>ty_qty_tt.

    APPEND '-5' TO lt_demands.

    DATA(lt_grants) = mo_cut->allocate( it_demands  = lt_demands
                                        iv_capacity = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '0' ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_demands TYPE zcl_alloc_capacity=>ty_qty_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->allocate( it_demands  = lt_demands
                              iv_capacity = '10' ) ).
  ENDMETHOD.

ENDCLASS.
