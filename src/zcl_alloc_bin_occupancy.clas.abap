CLASS zcl_alloc_bin_occupancy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             capacity TYPE i,
             used     TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_stat,
             occupied        TYPE i,
             empty           TYPE i,
             total_used      TYPE i,
             total_capacity  TYPE i,
             avg_utilisation TYPE i,
           END OF ty_stat.

    METHODS analyse
      IMPORTING
        it_bins        TYPE ty_bin_tt
      RETURNING
        VALUE(rs_stat) TYPE ty_stat.

ENDCLASS.


CLASS zcl_alloc_bin_occupancy IMPLEMENTATION.

  METHOD analyse.
    LOOP AT it_bins INTO DATA(ls_bin).
      IF ls_bin-used > 0.
        rs_stat-occupied = rs_stat-occupied + 1.
      ELSE.
        rs_stat-empty = rs_stat-empty + 1.
      ENDIF.

      rs_stat-total_used = rs_stat-total_used + ls_bin-used.
      rs_stat-total_capacity = rs_stat-total_capacity + ls_bin-capacity.
    ENDLOOP.

    IF rs_stat-total_capacity > 0 AND rs_stat-total_used > 0.
      rs_stat-avg_utilisation = rs_stat-total_used * 100
                                DIV rs_stat-total_capacity.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
