INTERFACE zif_requirement_reader
  PUBLIC.

  TYPES ty_quantity TYPE menge_d.

  TYPES: BEGIN OF ty_requirement,
           id             TYPE c LENGTH 20,
           priority       TYPE i,
           requested_date TYPE d,
           unit           TYPE c LENGTH 3,
           requested_qty  TYPE ty_quantity,
         END OF ty_requirement.

  TYPES ty_requirement_tt TYPE STANDARD TABLE OF ty_requirement WITH DEFAULT KEY.

  METHODS read_requirements
    IMPORTING
      iv_matnr               TYPE matnr
      iv_werks               TYPE werks_d
    RETURNING
      VALUE(rt_requirements) TYPE ty_requirement_tt.

ENDINTERFACE.
