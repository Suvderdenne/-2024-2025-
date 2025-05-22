import {
    AccountTreeRounded,
    BadgeOutlined,
    CampaignRounded, ChecklistRounded,
    CorporateFareRounded,
    DashboardRounded, EventAvailableRounded, InsertInvitationRounded,
    PeopleRounded,
    ReceiptLongRounded,
    SettingsRounded
} from "@mui/icons-material";
import {generateUniqueId} from "utils/helper";
import {Role} from "../../constants/constants";

const Menus = [
    {
        navLabel: true,
        subheader: 'Нүүр хуудас',
    },
    {
        id: generateUniqueId(),
        title: 'Хяналтын самбар',
        icon: DashboardRounded,
        href: '',
        roles: [Role.employee.value],
    },
    // {
    //     navLabel: true,
    //     subheader: 'Компани',
    // },
    // {
    //     id: generateUniqueId(),
    //     title: 'Зарлал',
    //     icon: CampaignRounded,
    //     href: '/announcement',
    // },
    // {
    //     id: generateUniqueId(),
    //     title: 'Тэмдэглэл',
    //     icon: BadgeOutlined,
    //     href: '/designation',
    // },
    // {
    //     id: generateUniqueId(),
    //     title: 'Хэлтэс',
    //     icon: CorporateFareRounded,
    //     href: '/department',
    // },
    {
        navLabel: true,
        subheader: 'Ажилтан',
    },
    {
        id: generateUniqueId(),
        title: 'Ирц',
        icon: EventAvailableRounded,
        href: '/attendance',
        roles: [Role.employee.value],
    },
    {
        id: generateUniqueId(),
        title: 'Чөлөө',
        icon: InsertInvitationRounded,
        href: '/leave',
        roles: [Role.employee.value],
    },
    {
        navLabel: true,
        subheader: 'Төсөл',
    },
    {
        id: generateUniqueId(),
        title: 'Төсөл',
        icon: AccountTreeRounded,
        href: '/project',
    },
    {
        id: generateUniqueId(),
        title: 'Даалгавар',
        icon: ChecklistRounded,
        href: '/task',
        roles: [Role.employee.value],
    },
    // {
    //     navLabel: true,
    //     subheader: 'Санхүү',
    // },
    // {
    //     id: generateUniqueId(),
    //     title: 'Зарлага',
    //     icon: ReceiptLongRounded,
    //     href: '/expense',
    // },
    {
        navLabel: true,
        subheader: 'Тохиргоо',
    },
    {
        id: generateUniqueId(),
        title: 'Хувийн мэдээлэл',
        icon: SettingsRounded,
        href: '/setting',
    },
    {
        id: generateUniqueId(),
        title: 'Хэрэглэгчид',
        icon: PeopleRounded,
        href: '/user',
    },
];

export default Menus;