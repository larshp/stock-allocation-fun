CLASS ltcl_alloc_field_auth DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_field_auth.

    METHODS setup.

    METHODS hides_field            FOR TESTING.
    METHODS visible_when_not_hidden FOR TESTING.
    METHODS counts_visible         FOR TESTING.
    METHODS hides_duplicate        FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_field_auth IMPLEMENTATION.

  METHOD setup.
    DATA lt_hidden TYPE zcl_alloc_field_auth=>ty_field_tt.
    DATA lv_field  TYPE zcl_alloc_field_auth=>ty_field.

    lv_field = 'MATNR'.
    APPEND lv_field TO lt_hidden.

    lv_field = 'WERKS'.
    APPEND lv_field TO lt_hidden.

    mo_cut = NEW zcl_alloc_field_auth( lt_hidden ).
  ENDMETHOD.

  METHOD hides_field.
    DATA lv_visible TYPE abap_bool.

    lv_visible = mo_cut->is_visible( 'MATNR' ).

    cl_abap_unit_assert=>assert_equals( act = lv_visible exp = abap_false ).
  ENDMETHOD.

  METHOD visible_when_not_hidden.
    DATA lv_visible TYPE abap_bool.

    lv_visible = mo_cut->is_visible( 'LGORT' ).

    cl_abap_unit_assert=>assert_equals( act = lv_visible exp = abap_true ).
  ENDMETHOD.

  METHOD counts_visible.
    DATA lt_fields TYPE zcl_alloc_field_auth=>ty_field_tt.
    DATA lv_field  TYPE zcl_alloc_field_auth=>ty_field.

    lv_field = 'MATNR'.
    APPEND lv_field TO lt_fields.

    lv_field = 'LGORT'.
    APPEND lv_field TO lt_fields.

    lv_field = 'WERKS'.
    APPEND lv_field TO lt_fields.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->visible_count( lt_fields ) exp = 1 ).
  ENDMETHOD.

  METHOD hides_duplicate.
    mo_cut->hide( 'LGORT' ).
    mo_cut->hide( 'LGORT' ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_visible( 'LGORT' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
