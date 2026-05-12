if ! grep -q "int path_umount" fs/namespace.c; then
    cat <<EOF >> fs/namespace.c

int path_umount(struct path *path, int flags)
{
    struct mount *mnt = real_mount(path->mnt);
    int ret;

    if (flags & ~(MNT_FORCE | MNT_DETACH | MNT_EXPIRE | UMOUNT_NOFOLLOW))
        return -EINVAL;
    if (!may_mount())
        return -EPERM;
    if (path->dentry != path->mnt->mnt_root)
        return -EINVAL;

    ret = do_umount(mnt, flags);

    dput(path->dentry);
    mntput_no_expire(mnt);
    return ret;
}
EXPORT_SYMBOL(path_umount);
EOF
fi

sed -i '/int do_umount(/a int path_umount(struct path *path, int flags);' include/linux/fs.h
