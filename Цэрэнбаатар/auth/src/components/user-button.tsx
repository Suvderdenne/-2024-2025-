import Image from "next/image";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { signOut, useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { Loader } from "lucide-react";
import Link from "next/link";

const UserButton = () => {
    const router = useRouter();
    const { data: session, status } = useSession();

    if (status === "loading") {
        return <Loader className="w-6 h-6 animate-spin text-primary" />;
    }

    const avatarFallback = session?.user?.email?.charAt(0).toUpperCase();

    const handleSignOut = async () => {
        await signOut({ redirect: false });
        router.push("/");
    };

    return (
        <nav>
            {session ? (
                <DropdownMenu modal={false}>
                    <DropdownMenuTrigger className="btn btn-ghost btn-circle">
                        <div className="flex items-center gap-2">
                            <span className="hidden md:block text-sm font-semibold">{session.user?.email}</span>
                            <Avatar className="w-10 h-10 hover:opacity-80 transition">
                                <AvatarImage src={session.user?.image || undefined} />
                                <AvatarFallback className="bg-primary text-white">
                                    {avatarFallback}
                                </AvatarFallback>
                            </Avatar>
                        </div>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" side="bottom" className="menu bg-base-200 shadow-xl rounded-box w-52">
                        <DropdownMenuItem className="p-3 hover:bg-primary hover:text-white cursor-pointer">
                            <Link href="/dashboard" className="w-full h-full block">Зар нэмэх</Link>
                        </DropdownMenuItem>
                        <DropdownMenuItem className="p-3 hover:bg-primary hover:text-white cursor-pointer" onClick={handleSignOut}>
                            Гарах
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            ) : (
                <div className="flex items-center gap-2 mb-3">
                    <Link href="sign-in" className="btn btn-sm btn-outline">Нэвтрэх</Link>
                    <Link href="sign-up" className="btn btn-sm btn-primary">Бүртгүүлэх</Link>
                </div>
            )}
        </nav>
    );
};

export default function Header() {
    return (
        <div className="navbar bg-base-100 shadow-md flex justify-between px-5 mt-4">
            {/* Navbar Start - Logo & Mobile Menu */}
            <div className="flex items-center gap-4">
                <div className="dropdown lg:hidden">
                    <div tabIndex={0} role="button" className="btn btn-ghost">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h8m-8 6h16" />
                        </svg>
                    </div>
                    <ul tabIndex={0} className="menu menu-sm dropdown-content bg-base-100 rounded-box w-52  shadow">
                        <li><Link href="/">НҮҮР</Link></li>
                        <li><Link href="/medee">МЭДЭЭ</Link></li>
                        <li><Link href="/uneKhansh">ҮНЭ ХАНШ</Link></li>
                        <li><Link href="/agent">АГЕНТУУД</Link></li>
                        <li><Link href="/shine">ШИНЭ ОРОН СУУЦ</Link></li>
                        <li><Link href="/zaruud">БАЙРНЫ ЗАР</Link></li>
                    </ul>
                </div>
                <Link href="/" className="flex items-center">
                    <Image src="/logo.jpg" width={96} height={96} alt="Logo" className="h-14 w-auto" />
                </Link>
            </div>

            {/* Navbar Center - Desktop Navigation */}
            <div className="hidden lg:flex">
                <ul className="menu menu-horizontal px-2 font-semibold flex gap-8">
                    <li><Link href="/">НҮҮР</Link></li>
                    <li><Link href="/medee">МЭДЭЭ</Link></li>
                    <li><Link href="/uneKhansh">ҮНЭ ХАНШ</Link></li>
                    <li><Link href="/agent">АГЕНТУУД</Link></li>
                    <li><Link href="/shine">ШИНЭ ОРОН СУУЦ</Link></li>
                    <li><Link href="/zaruud">БАЙРНЫ ЗАР</Link></li>
                </ul>
            </div>

            {/* Navbar End - User Actions */}
            <div className="flex items-center gap-3">
                
                <UserButton />
            </div>
        </div>
    );
}
