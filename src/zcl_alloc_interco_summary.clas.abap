CLASS zcl_alloc_interco_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             entity TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             entity_count TYPE i,
             total        TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS entity_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_entity,
             entity TYPE string,
           END OF ty_entity.

ENDCLASS.


CLASS zcl_alloc_interco_summary IMPLEMENTATION.

  METHOD total.
    " The summary total adds up the intercompany amounts.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD entity_count.
    DATA lt_entity TYPE SORTED TABLE OF ty_entity WITH UNIQUE KEY entity.
    DATA ls_entity TYPE ty_entity.

    " The count is the number of distinct entities behind the amounts.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_entity INTO ls_entity WITH KEY entity = ls_line-entity.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_entity.
      ls_entity-entity = ls_line-entity.
      INSERT ls_entity INTO TABLE lt_entity.
    ENDLOOP.

    rv_count = lines( lt_entity ).
  ENDMETHOD.

  METHOD build.
    " The result counts the entities and totals their amounts.
    rs_summary-entity_count = entity_count( it_lines ).
    rs_summary-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
