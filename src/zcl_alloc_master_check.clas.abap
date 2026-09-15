CLASS zcl_alloc_master_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_matnr_tt TYPE STANDARD TABLE OF matnr WITH DEFAULT KEY.
    TYPES ty_werks_tt TYPE STANDARD TABLE OF werks_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_request,
             matnr TYPE matnr,
             werks TYPE werks_d,
           END OF ty_request.
    TYPES ty_request_tt TYPE STANDARD TABLE OF ty_request WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             requests  TYPE ty_request_tt,
             materials TYPE ty_matnr_tt,
             plants    TYPE ty_werks_tt,
           END OF ty_input.

    TYPES: BEGIN OF ty_issue,
             matnr   TYPE matnr,
             werks   TYPE werks_d,
             message TYPE c LENGTH 80,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS check
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

  PRIVATE SECTION.
    METHODS material_known
      IMPORTING
        it_materials    TYPE ty_matnr_tt
        iv_matnr        TYPE matnr
      RETURNING
        VALUE(rv_known) TYPE abap_bool.

    METHODS plant_known
      IMPORTING
        it_plants       TYPE ty_werks_tt
        iv_werks        TYPE werks_d
      RETURNING
        VALUE(rv_known) TYPE abap_bool.

    METHODS add_issue
      IMPORTING
        is_request       TYPE ty_request
        iv_message       TYPE string
        it_issues        TYPE ty_issue_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

ENDCLASS.


CLASS zcl_alloc_master_check IMPLEMENTATION.

  METHOD material_known.
    rv_known = abap_false.
    LOOP AT it_materials INTO DATA(lv_matnr).
      IF lv_matnr = iv_matnr.
        rv_known = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD plant_known.
    rv_known = abap_false.
    LOOP AT it_plants INTO DATA(lv_werks).
      IF lv_werks = iv_werks.
        rv_known = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_issue.
    DATA ls_issue TYPE ty_issue.

    rt_issues = it_issues.

    ls_issue-matnr = is_request-matnr.
    ls_issue-werks = is_request-werks.
    ls_issue-message = iv_message.
    APPEND ls_issue TO rt_issues.
  ENDMETHOD.

  METHOD check.
    LOOP AT is_input-requests INTO DATA(ls_request).
      IF material_known( it_materials = is_input-materials
                         iv_matnr     = ls_request-matnr ) = abap_false.
        rt_issues = add_issue( is_request = ls_request
                               iv_message = 'Material master is missing'
                               it_issues  = rt_issues ).
      ENDIF.

      IF plant_known( it_plants = is_input-plants
                      iv_werks  = ls_request-werks ) = abap_false.
        rt_issues = add_issue( is_request = ls_request
                               iv_message = 'Plant is missing'
                               it_issues  = rt_issues ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
