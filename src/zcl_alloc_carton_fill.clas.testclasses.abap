CLASS ltcl_alloc_carton_fill DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_carton_fill.

    METHODS setup.

    METHODS half_full      FOR TESTING.
    METHODS clamps_large   FOR TESTING.
    METHODS fits_when_in   FOR TESTING.
    METHODS does_not_fit   FOR TESTING.
    METHODS fits_zero_box  FOR TESTING.
    METHODS needs_one      FOR TESTING.
    METHODS needs_two      FOR TESTING.
    METHODS empty_volumes  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_carton_fill IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_carton_fill( ).
  ENDMETHOD.

  METHOD half_full.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fill_percent( iv_item_volume = 50 iv_carton_volume = 100 )
      exp = 50 ).
  ENDMETHOD.

  METHOD clamps_large.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fill_percent( iv_item_volume = 120 iv_carton_volume = 100 )
      exp = 120 ).
  ENDMETHOD.

  METHOD fits_when_in.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( iv_item_volume = 100 iv_carton_volume = 100 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD does_not_fit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( iv_item_volume = 101 iv_carton_volume = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD fits_zero_box.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( iv_item_volume = 0 iv_carton_volume = 0 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD needs_one.
    DATA lt_volumes TYPE zcl_alloc_carton_fill=>ty_volume_tt.

    APPEND VALUE #( volume = 40 ) TO lt_volumes.
    APPEND VALUE #( volume = 30 ) TO lt_volumes.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cartons_needed( it_volumes       = lt_volumes
                                    iv_carton_volume = 100 )
      exp = 1 ).
  ENDMETHOD.

  METHOD needs_two.
    DATA lt_volumes TYPE zcl_alloc_carton_fill=>ty_volume_tt.

    APPEND VALUE #( volume = 70 ) TO lt_volumes.
    APPEND VALUE #( volume = 40 ) TO lt_volumes.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cartons_needed( it_volumes       = lt_volumes
                                    iv_carton_volume = 100 )
      exp = 2 ).
  ENDMETHOD.

  METHOD empty_volumes.
    DATA lt_volumes TYPE zcl_alloc_carton_fill=>ty_volume_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cartons_needed( it_volumes       = lt_volumes
                                    iv_carton_volume = 100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
