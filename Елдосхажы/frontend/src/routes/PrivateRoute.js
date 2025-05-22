import Dashboard from "../pages/Dashboard";
import {DashboardRounded} from "@mui/icons-material";
import Announcement from "../pages/announcement/Announcement";
import AnnouncementForm from "../pages/announcement/AnnouncementForm";
import Attendance from "../pages/attendance/Attendance";
import AttendanceForm from "../pages/attendance/AttendanceForm";
import User from "../pages/user/User";
import UserForm from "../pages/user/UserForm";
import Department from "../pages/department/Department";
import DepartmentForm from "../pages/department/DepartmentForm";
import Designation from "../pages/designation/Designation";
import DesignationForm from "../pages/designation/DesignationForm";
import Leave from "../pages/leave/Leave";
import LeaveForm from "../pages/leave/LeaveForm";
import Project from "../pages/project/Project";
import ProjectForm from "../pages/project/ProjectForm";
import Task from "../pages/task/Task";
import TaskForm from "../pages/task/TaskForm";
import Expense from "../pages/expense/Expense";
import ExpenseForm from "../pages/expense/ExpenseForm";
import SettingForm from "../pages/setting/SettingForm";

export const routes = [
    {
        name: 'Dashboard',
        path: '/app',
        component: Dashboard,
    },
    {
        name: 'Announcement',
        path: '/app/announcement',
        component: Announcement,
    },
    {
        name: 'Create Announcement',
        path: '/app/announcement/create',
        component: AnnouncementForm,
    },
    {
        name: 'Update Announcement',
        path: '/app/announcement/:id/update',
        component: AnnouncementForm,
    },
    {
        name: 'Attendance',
        path: '/app/attendance',
        component: Attendance,
    },
    {
        name: 'Create Attendance',
        path: '/app/attendance/create',
        component: AttendanceForm,
    },
    {
        name: 'Update Attendance',
        path: '/app/attendance/:id/update',
        component: AttendanceForm,
    },
    {
        name: 'Department',
        path: '/app/department',
        component: Department,
    },
    {
        name: 'Create Department',
        path: '/app/department/create',
        component: DepartmentForm,
    },
    {
        name: 'Update Department',
        path: '/app/department/:id/update',
        component: DepartmentForm,
    },
    {
        name: 'Designation',
        path: '/app/designation',
        component: Designation,
    },
    {
        name: 'Create Designation',
        path: '/app/designation/create',
        component: DesignationForm,
    },
    {
        name: 'Update Designation',
        path: '/app/designation/:id/update',
        component: DesignationForm,
    },
    {
        name: 'Expense',
        path: '/app/expense',
        component: Expense,
    },
    {
        name: 'Create Expense',
        path: '/app/expense/create',
        component: ExpenseForm,
    },
    {
        name: 'Update Expense',
        path: '/app/expense/:id/update',
        component: ExpenseForm,
    },
    {
        name: 'Leave',
        path: '/app/leave',
        component: Leave,
    },
    {
        name: 'Create Leave',
        path: '/app/leave/create',
        component: LeaveForm,
    },
    {
        name: 'Update Leave',
        path: '/app/leave/:id/update',
        component: LeaveForm,
    },
    {
        name: 'Project',
        path: '/app/project',
        component: Project,
    },
    {
        name: 'Create Project',
        path: '/app/project/create',
        component: ProjectForm,
    },
    {
        name: 'Update Project',
        path: '/app/project/:id/update',
        component: ProjectForm,
    },
    {
        name: 'Task',
        path: '/app/task',
        component: Task,
    },
    {
        name: 'Create Task',
        path: '/app/task/create',
        component: TaskForm,
    },
    {
        name: 'Update Task',
        path: '/app/task/:id/update',
        component: TaskForm,
    },
    {
        name: 'User',
        path: '/app/user',
        component: User,
    },
    {
        name: 'Create User',
        path: '/app/user/create',
        component: UserForm,
    },
    {
        name: 'Update User',
        path: '/app/user/:id/update',
        component: UserForm,
    },
    {
        name: 'Update Setting',
        path: '/app/setting',
        component: SettingForm,
    },
];