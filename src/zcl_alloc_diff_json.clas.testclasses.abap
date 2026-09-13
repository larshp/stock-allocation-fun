CLASS ltcl_alloc_diff_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_diff_json.

    METHODS setup.

    METHODS line
      IMPORTING
        iv_id         TYPE zcl_alloc_diff=>ty_line-requirement_id
        iv_old        TYPE menge_d
        iv_new        TYPE menge_d
        iv_type       TYPE zcl_alloc_diff=>ty_line-change_type
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_diff=>ty_line.

    METHODS empty_result   FOR TESTING.
    METHODS line_fields    FOR TESTING.
    METHODS summary_fields FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_diff_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_diff_json( ).
  ENDMETHOD.

  METHOD line.
    rs_row-requirement_id = iv_id.
    rs_row-old_qty = iv_old.
    rs_row-new_qty = iv_new.
    rs_row-delta_qty = iv_new - iv_old.
    rs_row-change_type = iv_type.
  ENDMETHOD.

  METHOD empty_result.
    DATA ls_result TYPE zcl_alloc_diff=>ty_result.
    DATA lv_exp    TYPE string.

    lv_exp = '{"lines":[],"summary":{"added":0,"removed":0,'.
    lv_exp = lv_exp && '"changed":0,"unchanged":0,"old_total":0.000,'.
    lv_exp = lv_exp && '"new_total":0.000,"delta_total":0.000}}'.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( ls_result )
                                        exp = lv_exp ).
  ENDMETHOD.

  METHOD line_fields.
    DATA ls_result TYPE zcl_alloc_diff=>ty_result.

    APPEND line( iv_id   = 'REQ-1'
                 iv_old  = '4'
                 iv_new  = '6'
                 iv_type = '~' ) TO ls_result-lines.

    DATA(lv_json) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"old_qty":4.000,"new_qty":6.000' )
      exp = -1 ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"change_type":"~"' )
      exp = -1 ).
  ENDMETHOD.

  METHOD summary_fields.
    DATA ls_result TYPE zcl_alloc_diff=>ty_result.

    ls_result-summary-added = 1.
    ls_result-summary-old_total = '4'.
    ls_result-summary-new_total = '6'.
    ls_result-summary-delta_total = '2'.

    DATA(lv_json) = mo_cut->build( ls_result ).

    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"added":1' )
      exp = -1 ).
    cl_abap_unit_assert=>assert_differs(
      act = find( val = lv_json sub = '"delta_total":2.000' )
      exp = -1 ).
  ENDMETHOD.

ENDCLASS.
