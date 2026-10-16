CLASS ltcl_alloc_load_balance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_load_balance.

    METHODS setup.

    METHODS even_split        FOR TESTING.
    METHODS limited_first     FOR TESTING.
    METHODS total_insufficient FOR TESTING.
    METHODS zero_availability FOR TESTING.
    METHODS zero_demand       FOR TESTING.
    METHODS empty_list        FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_load_balance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_load_balance( ).
  ENDMETHOD.

  METHOD even_split.
    DATA lt_avail TYPE zcl_alloc_load_balance=>ty_qty_tt.

    APPEND '10' TO lt_avail.
    APPEND '10' TO lt_avail.

    DATA(lt_grants) = mo_cut->balance( it_availability = lt_avail
                                       iv_demand       = '4' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '2' ).
  ENDMETHOD.

  METHOD limited_first.
    DATA lt_avail TYPE zcl_alloc_load_balance=>ty_qty_tt.

    APPEND '1' TO lt_avail.
    APPEND '10' TO lt_avail.

    DATA(lt_grants) = mo_cut->balance( it_availability = lt_avail
                                       iv_demand       = '6' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '5' ).
  ENDMETHOD.

  METHOD total_insufficient.
    DATA lt_avail TYPE zcl_alloc_load_balance=>ty_qty_tt.

    APPEND '3' TO lt_avail.
    APPEND '3' TO lt_avail.

    DATA(lt_grants) = mo_cut->balance( it_availability = lt_avail
                                       iv_demand       = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '3' ).
  ENDMETHOD.

  METHOD zero_availability.
    DATA lt_avail TYPE zcl_alloc_load_balance=>ty_qty_tt.

    APPEND '0' TO lt_avail.
    APPEND '0' TO lt_avail.

    DATA(lt_grants) = mo_cut->balance( it_availability = lt_avail
                                       iv_demand       = '5' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 2 ]-granted exp = '0' ).
  ENDMETHOD.

  METHOD zero_demand.
    DATA lt_avail TYPE zcl_alloc_load_balance=>ty_qty_tt.

    APPEND '5' TO lt_avail.

    DATA(lt_grants) = mo_cut->balance( it_availability = lt_avail
                                       iv_demand       = '0' ).

    cl_abap_unit_assert=>assert_equals( act = lt_grants[ 1 ]-granted exp = '0' ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_avail TYPE zcl_alloc_load_balance=>ty_qty_tt.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->balance( it_availability = lt_avail
                             iv_demand       = '5' ) ).
  ENDMETHOD.

ENDCLASS.
