CLASS ltcl_alloc_truck_fill DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_truck_fill.
    DATA mt_loa TYPE zcl_alloc_truck_fill=>ty_load_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_weight TYPE i
        iv_volume TYPE i.

    METHODS sums_totals    FOR TESTING.
    METHODS fits_exact     FOR TESTING.
    METHODS too_heavy      FOR TESTING.
    METHODS weight_limits  FOR TESTING.
    METHODS volume_limits  FOR TESTING.
    METHODS unconstrained  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_truck_fill IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_truck_fill( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_load TYPE zcl_alloc_truck_fill=>ty_load.

    ls_load-weight = iv_weight.
    ls_load-volume = iv_volume.
    APPEND ls_load TO mt_loa.
  ENDMETHOD.

  METHOD sums_totals.
    DATA ls_res TYPE zcl_alloc_truck_fill=>ty_result.

    add( iv_weight = 100 iv_volume = 10 ).
    add( iv_weight = 50 iv_volume = 5 ).

    ls_res = mo_cut->check( it_load = mt_loa iv_max_weight = 1000
                            iv_max_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-weight exp = 150 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-volume exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-weight_pct exp = 15 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-volume_pct exp = 15 ).
  ENDMETHOD.

  METHOD fits_exact.
    DATA ls_res TYPE zcl_alloc_truck_fill=>ty_result.

    add( iv_weight = 500 iv_volume = 50 ).

    ls_res = mo_cut->check( it_load = mt_loa iv_max_weight = 500
                            iv_max_volume = 50 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-fits exp = abap_true ).
  ENDMETHOD.

  METHOD too_heavy.
    DATA ls_res TYPE zcl_alloc_truck_fill=>ty_result.

    add( iv_weight = 501 iv_volume = 10 ).

    ls_res = mo_cut->check( it_load = mt_loa iv_max_weight = 500
                            iv_max_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-fits exp = abap_false ).
  ENDMETHOD.

  METHOD weight_limits.
    DATA ls_res TYPE zcl_alloc_truck_fill=>ty_result.

    add( iv_weight = 900 iv_volume = 10 ).

    ls_res = mo_cut->check( it_load = mt_loa iv_max_weight = 1000
                            iv_max_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-limiting exp = 'WEIGHT' ).
  ENDMETHOD.

  METHOD volume_limits.
    DATA ls_res TYPE zcl_alloc_truck_fill=>ty_result.

    add( iv_weight = 100 iv_volume = 90 ).

    ls_res = mo_cut->check( it_load = mt_loa iv_max_weight = 1000
                            iv_max_volume = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-limiting exp = 'VOLUME' ).
  ENDMETHOD.

  METHOD unconstrained.
    DATA ls_res TYPE zcl_alloc_truck_fill=>ty_result.

    add( iv_weight = 100 iv_volume = 10 ).

    ls_res = mo_cut->check( it_load = mt_loa iv_max_weight = 0
                            iv_max_volume = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-fits exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-limiting exp = 'NONE' ).
  ENDMETHOD.

ENDCLASS.
