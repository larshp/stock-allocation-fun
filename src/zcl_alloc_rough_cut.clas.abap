CLASS zcl_alloc_rough_cut DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_demand,
             work_centre TYPE string,
             required    TYPE menge_d,
           END OF ty_demand.
    TYPES ty_demand_tt TYPE STANDARD TABLE OF ty_demand WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_capacity,
             work_centre TYPE string,
             available   TYPE menge_d,
           END OF ty_capacity.
    TYPES ty_capacity_tt TYPE STANDARD TABLE OF ty_capacity WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             work_centre TYPE string,
             required    TYPE menge_d,
             available   TYPE menge_d,
             gap         TYPE menge_d,
             ok          TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS check
      IMPORTING
        it_demand       TYPE ty_demand_tt
        it_capacity     TYPE ty_capacity_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_feasible
      IMPORTING
        it_lines     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS gap_total
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_gap) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_rough_cut IMPLEMENTATION.

  METHOD check.
    DATA ls_line TYPE ty_line.

    LOOP AT it_demand INTO DATA(ls_demand).
      CLEAR ls_line.
      ls_line-work_centre = ls_demand-work_centre.
      ls_line-required = ls_demand-required.

      READ TABLE it_capacity INTO DATA(ls_cap)
        WITH KEY work_centre = ls_demand-work_centre.
      IF sy-subrc = 0.
        ls_line-available = ls_cap-available.
      ENDIF.

      ls_line-gap = ls_line-required - ls_line-available.

      IF ls_line-gap <= 0.
        ls_line-ok = abap_true.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_feasible.
    rv_ok = abap_true.

    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-ok = abap_false.
        rv_ok = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD gap_total.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-gap > 0.
        rv_gap = rv_gap + ls_line-gap.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
