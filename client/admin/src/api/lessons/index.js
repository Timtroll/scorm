import serverHttp from '@/api/serverHttp'


export default class lesson {

  constructor (userId) {
    this.userId = userId
  }

  async loadUsers (lessonUid) {
    if (!lessonUid) return
    return await serverHttp
      .query('/lesson/lesson_users', {uid: lessonUid}, false, true)
  }

}
