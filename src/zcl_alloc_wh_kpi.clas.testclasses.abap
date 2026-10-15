CLASS ltcl_alloc_wh_kpi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wh_kpi.
    DATA mt_kpi TYPE zcl_alloc_wh_kpi=>ty_kpi_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_value  TYPE i
        iv_target TYPE i
        iv_unit   TYPE string.

    METHODS card_values   FOR TESTING.
    METHODS on_target_yes FOR TESTING.
    METHODS on_target_no  FOR TESTING.
    METHODS no_target     FOR TESTING.
    METHODS counts_target FOR TESTING.
    METHODS empty_list    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wh_kpi IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wh_kpi( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_kpi TYPE zcl_alloc_wh_kpi=>ty_kpi.

    ls_kpi-name = iv_name.
    ls_kpi-value = iv_value.
    ls_kpi-target = iv_target.
    ls_kpi-unit = iv_unit.
    APPEND ls_kpi TO mt_kpi.
  ENDMETHOD.

  METHOD card_values.
    DATA lt_card TYPE zcl_alloc_wh_kpi=>ty_card_tt.

    add( iv_name = 'LPH' iv_value = 180 iv_target = 200 iv_unit = 'L/H' ).

    lt_card = mo_cut->build( mt_kpi ).

    cl_abap_unit_assert=>assert_equals( act = lt_card[ 1 ]-name exp = 'LPH' ).
    cl_abap_unit_assert=>assert_equals( act = lt_card[ 1 ]-value exp = 180 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_card[ 1 ]-achievement exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_card[ 1 ]-unit exp = 'L/H' ).
  ENDMETHOD.

  METHOD on_target_yes.
    DATA lt_card TYPE zcl_alloc_wh_kpi=>ty_card_tt.

    add( iv_name = 'ACCURACY' iv_value = 99 iv_target = 95 iv_unit = '%' ).

    lt_card = mo_cut->build( mt_kpi ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_card[ 1 ]-on_target exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_card[ 1 ]-achievement exp = 104 ).
  ENDMETHOD.

  METHOD on_target_no.
    DATA lt_card TYPE zcl_alloc_wh_kpi=>ty_card_tt.

    add( iv_name = 'LPH' iv_value = 160 iv_target = 200 iv_unit = 'L/H' ).

    lt_card = mo_cut->build( mt_kpi ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_card[ 1 ]-on_target exp = abap_false ).
  ENDMETHOD.

  METHOD no_target.
    DATA lt_card TYPE zcl_alloc_wh_kpi=>ty_card_tt.

    add( iv_name = 'LPH' iv_value = 160 iv_target = 0 iv_unit = 'L/H' ).

    lt_card = mo_cut->build( mt_kpi ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_card[ 1 ]-achievement exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_card[ 1 ]-on_target exp = abap_false ).
  ENDMETHOD.

  METHOD counts_target.
    DATA lt_card TYPE zcl_alloc_wh_kpi=>ty_card_tt.

    add( iv_name = 'LPH' iv_value = 180 iv_target = 200 iv_unit = 'L/H' ).
    add( iv_name = 'ACCURACY' iv_value = 99 iv_target = 95 iv_unit = '%' ).
    add( iv_name = 'IDLE' iv_value = 10 iv_target = 0 iv_unit = 'MIN' ).

    lt_card = mo_cut->build( mt_kpi ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_card ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_target_count( lt_card ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_card TYPE zcl_alloc_wh_kpi=>ty_card_tt.

    lt_card = mo_cut->build( mt_kpi ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_card ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->on_target_count( lt_card ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
