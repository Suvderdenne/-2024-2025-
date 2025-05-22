import { useEffect, useState } from "react";
import { DefaultSort } from "../../constants/sort";
import useSWR from "swr";
import Breadcrumb from "../../components/Breadcrumb";
import {
  Box,
  Button,
  ButtonGroup,
  Card,
  CardContent,
  CircularProgress,
  Fab,
  IconButton,
  MenuItem,
  Pagination,
  Select,
  Stack,
  Tooltip,
  FormLabel,
} from "@mui/material";
import moment from "moment";
import EnhancedTableToolbar from "../../components/table/EnhancedTableToolbar";
import CustomCheckbox from "../../components/forms/CustomCheckbox";
import { Link } from "react-router-dom";
import { AddRounded, EditRounded } from "@mui/icons-material";
import DeleteConfirmDialog from "../../components/dialogs/DeleteConfirmDialog";
import {
  DeleteAttendance,
  GetAttendancesByQuery,
  CreateAttendance,
  UpdateAttendance,
} from "../../service/attendance";
import { DefaultSwrOptions, Role } from "../../constants/constants";
import { useSelector } from "react-redux";
import { GetUsersByQuery } from "../../service/user";

export default function Attendance() {
  const { role, profile } = useSelector((state) => state.profile);

  // Фильтр параметрлері (мысалы, sort, time)
  const [filter, setFilter] = useState({ sort: DefaultSort.newest.value });
  const [deleteConfirm, setDeleteConfirm] = useState(false);
  const [selectedItems, setSelectedItems] = useState([]);

  // SWR көмегімен attendance жазбаларын алу
  const { data: resData, isLoading: loading, mutate } = useSWR(
    ["/api/attendance", filter],
    () => GetAttendancesByQuery(filter),
    DefaultSwrOptions
  );

  // Ажилтан тізімін алу (админдер үшін Select-та көрсету)
  const { data: userRes } = useSWR("/api/user", () => GetUsersByQuery());

  // Admin үшін, қолданушы таңдау Select-і; employee үшін, автоматты түрде profile.id қолданылады
  const [selectedUser, setSelectedUser] = useState(
    role === Role.employee.value ? profile.id : ""
  );

  // Егер employee болса, filter-ге өз ID-сін орнатамыз
  useEffect(() => {
    if (role === Role.employee.value) {
      setFilter({ ...filter, userId: profile?.id });
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [role, profile]);

  // Жаппай өшіру функциясы (тек admin қолданушысы үшін)
  const handleDelete = () => {
    return DeleteAttendance(selectedItems.join(",")).then((res) => {
      if (res.status === 200) {
        mutate();
        setDeleteConfirm(false);
        setSelectedItems([]);
      }
    });
  };

  // Әр жолды таңдау (checkbox) — тек admin-ге көрінеді
  const handleSelectItems = (id) => {
    if (selectedItems.includes(id)) {
      setSelectedItems(selectedItems.filter((e) => e !== id));
    } else {
      setSelectedItems([...selectedItems, id]);
    }
  };

  // Уақыт сүзгісі (today, week, month)
  const handleSelectTime = (time) => {
    setFilter({ ...filter, time: time });
  };

  /**
   * handleCheckInNew – "Бүртгүүлэх" батырмасы.
   * IP мекенжайы ipify API арқылы алынады.
   * Employee үшін автоматты түрде profile.id, admin болса таңдалған user қолдану.
   */
  const handleCheckInNew = async () => {
    const userIdToUse = role === Role.employee.value ? profile.id : selectedUser;
    if (!userIdToUse) return; // Егер admin қолданушы ешнәрсе таңдамаса

    // Клиенттің сыртқы IP мекенжайын алу (ipify)
    let ipFetched = "";
    try {
      const resp = await fetch("https://api.ipify.org?format=json");
      const data = await resp.json();
      ipFetched = data.ip; // Мысалы, "203.0.113.42"
    } catch (err) {
      console.error("Failed to fetch IP address", err);
      ipFetched = "0.0.0.0"; // Қате болса, әдепкі мән
    }

    const payload = {
      userId: userIdToUse,
      checkIn: new Date().toISOString(),
      ipAddress: ipFetched,
    };

    CreateAttendance(payload).then((res) => {
      if (res.status === 200) {
        mutate();
        if (role === Role.admin.value) setSelectedUser("");
      } else {
        console.error("CreateAttendance error:", res);
      }
    });
  };

  /**
   * handleCheckOut – "Гарах" батырмасы.
   * Ағымдағы уақытпен checkOut өрісін жаңартады.
   */
  const handleCheckOut = (attendanceId) => {
    UpdateAttendance(attendanceId, { checkOut: new Date().toISOString() })
      .then((res) => {
        if (res.status === 200) {
          mutate();
        } else {
          console.error("CheckOut error:", res);
        }
      })
      .catch((err) => console.error("CheckOut error:", err));
  };

  return (
    <>
      <Breadcrumb
        title="Ирц"
        items={[
          { to: "/app", title: "Хяналтын самбар" },
          { title: "Ирц" },
        ]}
      />
      <Card>
        <CardContent>
          {/* Фильтр және жаппай өшіру */}
          <EnhancedTableToolbar
            filter={filter}
            numSelected={selectedItems.length}
            handleChange={(newFilter) => setFilter({ ...filter, ...newFilter })}
            sortItems={DefaultSort}
            onDelete={() => setDeleteConfirm(true)}
            actions={
              <ButtonGroup variant="outlined" size="small">
                <Button
                  onClick={() => handleSelectTime("today")}
                  variant={filter?.time === "today" ? "contained" : "outlined"}
                >
                  Өнөөдөр
                </Button>
                <Button
                  sx={{ width: 100 }}
                  onClick={() => handleSelectTime("week")}
                  variant={filter?.time === "week" ? "contained" : "outlined"}
                >
                  Энэ долоо хоног
                </Button>
                <Button
                  sx={{ width: 100 }}
                  onClick={() => handleSelectTime("month")}
                  variant={filter?.time === "month" ? "contained" : "outlined"}
                >
                  Энэ сар
                </Button>
              </ButtonGroup>
            }
          />

          {/* Жоғарыдағы аймақ: Ажилтан мен Бүртгүүлэх */}
          <Box display="flex" alignItems="center" gap={2} marginTop={2} marginBottom={3}>
            {role === Role.admin.value ? (
              <>
                <FormLabel>Ажилтан:</FormLabel>
                <Select
                  size="small"
                  value={selectedUser}
                  onChange={(e) => setSelectedUser(e.target.value)}
                  sx={{ width: 200 }}
                >
                  <MenuItem value="">Сонгох...</MenuItem>
                  {userRes?.data?.data?.map((u) => (
                    <MenuItem key={u.id} value={u.id}>
                      {u.name}
                    </MenuItem>
                  ))}
                </Select>
              </>
            ) : (
              // Employeeの場合: өз аты көрсетіледі
              <Box>{profile.name}</Box>
            )}
            {/* Екі жағдайда да Бүртгүүлэх батырмасы көрінеді */}
            <Button variant="contained" onClick={handleCheckInNew}>
            Ирц бүртгүүлэх
            </Button>
          </Box>

          {/* Кесте */}
          {loading || loading === undefined ? (
            <Stack alignItems="center">
              <Box height={20} />
              <CircularProgress size={32} />
            </Stack>
          ) : (
            <>
              <Box>
                <table style={{ width: "100%", borderCollapse: "collapse" }}>
                  <thead>
                    <tr style={{ textAlign: "left" }}>
                      {/* Checkbox бағаны, тек admin қолданушысына арналған */}
                      {role === Role.admin.value && <th style={{ width: "40px" }} />}
                      <th>Хэрэглэгч</th>
                      <th>Бүртгүүлсэн</th>
                      <th>IP хаяг</th>
                      <th>Гарах</th>
                      {/* Засах бағаны, тек admin үшін */}
                      {role === Role.admin.value && (
                        <th style={{ textAlign: "right" }}>Засах</th>
                      )}
                    </tr>
                  </thead>
                  <tbody>
                    {resData?.data?.data?.length > 0 ? (
                      resData.data.data.map((row) => (
                        <tr key={row._id} style={{ borderBottom: "1px solid #ccc" }}>
                          {role === Role.admin.value && (
                            <td>
                              <CustomCheckbox
                                color="primary"
                                checked={selectedItems.includes(row._id)}
                                onChange={() => handleSelectItems(row._id)}
                              />
                            </td>
                          )}
                          <td>{row.user?.name ?? "-"}</td>
                          <td>
                            {row.checkIn
                              ? moment(row.checkIn).format("DD MMM YYYY HH:mm")
                              : "Бүртгүүлээгүй"}
                          </td>
                          <td>{row.ipAddress ?? "-"}</td>
                          <td>
                            {row.checkOut ? (
                              moment(row.checkOut).format("DD MMM YYYY HH:mm")
                            ) : (
                              <Button
                                variant="contained"
                                size="small"
                                color="primary"
                                onClick={() => handleCheckOut(row.id)}
                              >
                                Гарах
                              </Button>
                            )}
                          </td>
                          {role === Role.admin.value && (
                            <td style={{ textAlign: "right" }}>
                              <Link to={`/app/attendance/${row._id}/update`}>
                                <Tooltip title="Edit">
                                  <IconButton>
                                    <EditRounded
                                      fontSize="small"
                                      sx={{ color: "text.secondary" }}
                                    />
                                  </IconButton>
                                </Tooltip>
                              </Link>
                            </td>
                          )}
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td
                          colSpan={role === Role.admin.value ? 6 : 5}
                          style={{ textAlign: "center", padding: "20px" }}
                        >
                          No Data
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </Box>
              <Stack direction="row" paddingTop={3} justifyContent="end">
                <Pagination
                  color="secondary"
                  count={resData?.data?.pagination?.pages ?? 1}
                  page={parseInt(resData?.data?.pagination?.page)}
                  size="small"
                  onChange={(e, val) => setFilter({ ...filter, page: val })}
                />
              </Stack>
            </>
          )}
        </CardContent>
      </Card>

      {/* Admin үшін ғана "қосу" FAB батырмасы */}
      {role === Role.admin.value && (
        <Link to={`/app/attendance/create`}>
          <Tooltip title="Add Data">
            <Fab
              color="primary"
              aria-label="add"
              sx={{ position: "fixed", right: "25px", bottom: "15px" }}
            >
              <AddRounded />
            </Fab>
          </Tooltip>
        </Link>
      )}

      <DeleteConfirmDialog
        open={deleteConfirm}
        onClose={() => setDeleteConfirm(false)}
        onSubmit={handleDelete}
      />
    </>
  );
}