CLASS ltcl_alloc_outlier DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_outlier.
    DATA mt_ser TYPE zcl_alloc_outlier=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS mean_is_reported FOR TESTING.
    METHODS sd_is_reported   FOR TESTING.
    METHODS finds_spike      FOR TESTING.
    METHODS tight_threshold  FOR TESTING.
    METHODS flat_series      FOR TESTING.
    METHODS empty_series     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_outlier IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_outlier( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD mean_is_reported.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mean_of( mt_ser ) exp = 28 ).
  ENDMETHOD.

  METHOD sd_is_reported.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sd_of( mt_ser ) exp = 36 ).
  ENDMETHOD.

  METHOD finds_spike.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 100 ).

    DATA(lt_hits) = mo_cut->find( it_series    = mt_ser
                                  iv_threshold = 150 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-rank exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-value exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-score_x100 exp = 200 ).
  ENDMETHOD.

  METHOD tight_threshold.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 100 ).

    DATA(lt_hits) = mo_cut->find( it_series    = mt_ser
                                  iv_threshold = 250 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 0 ).
  ENDMETHOD.

  METHOD flat_series.
    add( iv_value = 10 ).
    add( iv_value = 10 ).

    DATA(lt_hits) = mo_cut->find( it_series    = mt_ser
                                  iv_threshold = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->sd_of( mt_ser ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_series.
    DATA(lt_hits) = mo_cut->find( it_series    = mt_ser
                                  iv_threshold = 100 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->mean_of( mt_ser ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
