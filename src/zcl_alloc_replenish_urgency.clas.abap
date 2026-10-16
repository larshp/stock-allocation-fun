CLASS zcl_alloc_replenish_urgency DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS urgency
      IMPORTING
        iv_cover_days   TYPE i
      RETURNING
        VALUE(rv_level) TYPE i.

    METHODS is_urgent
      IMPORTING
        iv_urgency   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS priority_of
      IMPORTING
        iv_urgency         TYPE i
      RETURNING
        VALUE(rv_priority) TYPE string.

ENDCLASS.


CLASS zcl_alloc_replenish_urgency IMPLEMENTATION.

  METHOD urgency.
    " The cover collapses the urgency into four levels, the shortest cover first.
    IF iv_cover_days <= 0.
      rv_level = 3.
    ELSEIF iv_cover_days <= 3.
      rv_level = 2.
    ELSEIF iv_cover_days <= 7.
      rv_level = 1.
    ELSE.
      rv_level = 0.
    ENDIF.
  ENDMETHOD.

  METHOD is_urgent.
    " A high or critical level counts as urgent.
    rv_ok = xsdbool( iv_urgency >= 2 ).
  ENDMETHOD.

  METHOD priority_of.
    CASE iv_urgency.
      WHEN 3.
        rv_priority = 'CRITICAL'.
      WHEN 2.
        rv_priority = 'HIGH'.
      WHEN 1.
        rv_priority = 'MEDIUM'.
      WHEN OTHERS.
        rv_priority = 'LOW'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
