CLASS zcl_alloc_label_map DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_field,
             name  TYPE string,
             value TYPE string,
           END OF ty_field.
    TYPES ty_field_tt TYPE STANDARD TABLE OF ty_field WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_mapping,
             target TYPE string,
             source TYPE string,
           END OF ty_mapping.
    TYPES ty_mapping_tt TYPE STANDARD TABLE OF ty_mapping WITH DEFAULT KEY.

    METHODS apply
      IMPORTING
        it_mapping       TYPE ty_mapping_tt
        it_source        TYPE ty_field_tt
      RETURNING
        VALUE(rt_result) TYPE ty_field_tt.

ENDCLASS.


CLASS zcl_alloc_label_map IMPLEMENTATION.

  METHOD apply.
    DATA ls_result TYPE ty_field.
    DATA lv_found  TYPE abap_bool.

    " The mapping decides the order and the target names. A source field that is
    " not present yields an empty target rather than a missing line, so the label
    " layout never shifts.
    LOOP AT it_mapping INTO DATA(ls_mapping).
      CLEAR ls_result.
      CLEAR lv_found.

      ls_result-name = ls_mapping-target.

      READ TABLE it_source INTO DATA(ls_source)
        WITH KEY name = ls_mapping-source.
      IF sy-subrc = 0.
        ls_result-value = ls_source-value.
        lv_found = abap_true.
      ENDIF.

      APPEND ls_result TO rt_result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
