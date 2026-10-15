CLASS zcl_alloc_disposition DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_grade_item,
             grade TYPE string,
           END OF ty_grade_item.
    TYPES ty_grade_tt TYPE STANDARD TABLE OF ty_grade_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_count,
             target TYPE string,
             count  TYPE i,
           END OF ty_count.
    TYPES ty_count_tt TYPE STANDARD TABLE OF ty_count WITH DEFAULT KEY.

    METHODS route
      IMPORTING
        iv_grade         TYPE string
        iv_hazardous     TYPE abap_bool
      RETURNING
        VALUE(rv_target) TYPE string.

    METHODS target_of
      IMPORTING
        iv_grade         TYPE string
      RETURNING
        VALUE(rv_target) TYPE string.

    METHODS count_for
      IMPORTING
        it_grades        TYPE ty_grade_tt
      RETURNING
        VALUE(rt_counts) TYPE ty_count_tt.

ENDCLASS.


CLASS zcl_alloc_disposition IMPLEMENTATION.

  METHOD route.
    " A hazardous item is scrapped whatever its grade; otherwise the grade picks
    " the cheapest target that still protects the customer.
    IF iv_hazardous = abap_true.
      rv_target = 'SCRAP'.
      RETURN.
    ENDIF.

    CASE iv_grade.
      WHEN 'A' OR 'B'.
        rv_target = 'RESTOCK'.
      WHEN 'C'.
        rv_target = 'REWORK'.
      WHEN 'D'.
        rv_target = 'REPAIR'.
      WHEN 'F'.
        rv_target = 'SCRAP'.
    ENDCASE.
  ENDMETHOD.

  METHOD target_of.
    rv_target = route( iv_grade     = iv_grade
                       iv_hazardous = abap_false ).
  ENDMETHOD.

  METHOD count_for.
    DATA lt_count  TYPE SORTED TABLE OF ty_count WITH UNIQUE KEY target.
    DATA ls_count  TYPE ty_count.
    DATA lv_target TYPE string.

    LOOP AT it_grades INTO DATA(ls_grade).
      lv_target = target_of( ls_grade-grade ).

      READ TABLE lt_count ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY target = lv_target.

      IF sy-subrc <> 0.
        CLEAR ls_count.
        ls_count-target = lv_target.
        INSERT ls_count INTO TABLE lt_count ASSIGNING <ls_count>.
      ENDIF.

      <ls_count>-count = <ls_count>-count + 1.
    ENDLOOP.

    rt_counts = lt_count.
  ENDMETHOD.

ENDCLASS.
